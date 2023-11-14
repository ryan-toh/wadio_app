import SwiftUI

// Organisation

// 1st item: Slider to choose target IPPT Score if clicked
// 2nd item: UI to calcuate pushup, situp and 2.4km timing
// - to show the final IPPT score at the bottom right of the subview as a updating textfield
// 3rd item: An update button to send to HomeView the latest IPPT score obtained from the textfield

//   MARK: Layout
struct IpptView: View {
//    Class to store current and target IPPT scores
    @ObservedObject var ipptData: IpptData
    
    var body: some View {
        ZStack {
            Color(UIColor.secondarySystemBackground).ignoresSafeArea()
            VStack {
                List {
                    Section(header: Text("Goal")) {
                        GoalIpptView
                        LatestIpptView
                    }
                    Section(header: Text("Calculator")) {
                        IpptAgeView
                        CalculateIpptView
                        UpdateIpptScoreView
                    }
                }
            }
            .frame(maxWidth: 500)
            .navigationTitle("IPPT")
        }
    }
}

//  MARK: UI
extension IpptView {
//   Allows the user to set IPPT goal
    var GoalIpptView: some View {
        VStack {
            Picker(selection: $ipptData.latestTargetIpptScore) { 
//                 This allows you to set a goal that is higher than your current IPPT score
                if ipptData.latestIpptScore < 100 {
                    ForEach((ipptData.latestIpptScore + 1)...100, id: \.self) { value in
                        Text("\(value)" + (value == 61 ? " (NSF Pass)" : "")).tag(Int(value))
                    }
                }
                else {
                    Text("You did it!").tag(Int(100))
                }
            } label: { 
                HStack() {
                    Image(systemName: "medal.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 20)
                    Text("Target Score")
                        .font(.title)
//                    Image(systemName: "medal.fill")
                }
            }
            .pickerStyle(MenuPickerStyle())
            
        }
        .padding(.vertical, 10)
    }

//  Allows the user to enter their latest IPPT score
    var LatestIpptView: some View {
        Picker(selection: $ipptData.latestIpptScore) { 
            ForEach(0...100, id: \.self) { value in
                Text("\(value)").tag(Int(value))
            }
        } label: { 
            Text("Latest Score")
        }
        .pickerStyle(MenuPickerStyle())
    }
    
//    Allows the user to set Age for IPPT score calculation
    var IpptAgeView: some View {
        //    Age must be between 18 and 60 years old
        Picker(selection: $ipptData.userAge) { 
            ForEach(18...60, id: \.self) { value in
                Text("\(value) Years Old").tag(Int(value))
            }
        } label: { 
            Text("Age")
                .font(.title3)
        }
        .pickerStyle(MenuPickerStyle())
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
//    Main IPPT Calculator UI
    var CalculateIpptView: some View {
        VStack(alignment: .leading) {
//            2.4km Run
            HStack {
                Text("2.4km Run")
                    .font(.title3)
                Spacer()
            }
            HStack {
                Stepper(value: $ipptData.userRun,
                        in: 0...59,
                        step: 1) {
                    VStack {
                        HStack {
                            Image(systemName: "figure.run")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 50, maxHeight: 43)
                            Spacer()
                            Text(getRunTiming(timeInSeconds: runTimes[ipptData.userRun]))
                                .foregroundColor(Color.accentColor)
                                .font(.title)
                        }
                    }
                }
            }
            .padding(.bottom, 30)
//            Push Ups
            Text("Push Ups")
                .font(.title3)
            HStack {
                Stepper(value: $ipptData.userPushups,
                        in: 1...60,
                        step: 1) {
                    VStack {
                        HStack {
                            Image(systemName: "figure.curling")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 50, maxHeight: 43)
                            Spacer()
                            Text(String(ipptData.userPushups))
                                .foregroundColor(Color.accentColor)
                                .font(.title)
//                            Text((ipptData.userPushups != 1 ? " Push Ups" : " Push Up"))
//                                .font(.title3)
//                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            .padding(.bottom, 30)
//            Sit Ups
            Text("Sit Ups")
                .font(.title3)
            HStack {
                Stepper(value: $ipptData.userSitups,
                        in: 1...60,
                        step: 1) {
                    HStack {
                        Image(systemName: "figure.core.training")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 50, maxHeight: 40)
                        Spacer()
                        Text(String(ipptData.userSitups))
                            .font(.title)
                            .foregroundColor(Color.accentColor)
//                        Text((ipptData.userPushups != 1 ? " Sit Ups" : " Sit Up"))
//                            .font(.title3)
//                            .fontWeight(.semibold)
                    }
                }
            }
            .padding(.bottom, 50)
//            Final score
            Text("Total")
                .font(.title3)
            HStack {
                Text("Score")
                    .font(.title)
                    .fontWeight(.semibold)
                Spacer()
                Text(
                    String(calculateIpptScore(age: ipptData.userAge, pushupCount: ipptData.userPushups, situpCount: ipptData.userSitups, runCount: ipptData.userRun))
                )
                .foregroundColor(.accentColor)    
                .font(.title)
            }
            .padding(.bottom, 30)
        }
        .padding(.top, 20)
    }
    
//    Updates latest IPPT score based on calculation
    var UpdateIpptScoreView: some View {
        HStack {
            Spacer()
            Button(action: {
                ipptData.latestIpptScore = calculateIpptScore(age: ipptData.userAge, pushupCount: ipptData.userPushups, situpCount: ipptData.userSitups, runCount: ipptData.userRun)
            }, label: {
                Text("Update Score")
            })
            Spacer()
        }
    }
}



// MARK: Logic
extension IpptView {
    func getRunTiming(timeInSeconds: Int) -> String {
        let minute = Int(timeInSeconds / 60)
        let second = Int(timeInSeconds % 60)
        return "\(minute):\((second == 0 ? "00" : String(second)))"
    }
    
    func calculateIpptScore(age: Int, pushupCount: Int, situpCount: Int, runCount: Int) -> Int {
        /// valid between ages 18 to 60
        guard let ipptScoreAgeGroup: Int = ageGroup[age] else {
            return 0
        }
        let ipptPushupScore: Int = pushupScore[ipptScoreAgeGroup][pushupCount - 1]
        let ipptSitupScore: Int = situpScore[ipptScoreAgeGroup][situpCount - 1]
        let ipptRunScore: Int = runScore[ipptScoreAgeGroup][runCount]
        return ipptPushupScore + ipptSitupScore + ipptRunScore
    }
}


struct IpptView_Previews: PreviewProvider {
    static var previews: some View {
        IpptView(ipptData: IpptData())
    }
}
