import SwiftUI

// Plan

// Build the mainpage here

// Build a onboarding UI in a seperate swift file

// Build the IPPT UI in a seperate swift file

// Build the payday UI in a seperate swift file
// Control logic can be in another seperate swift file

// Initial intended features:
// 1. Show ORD date + circular graphic to show progress
// Note a. NS has 22 or 24 months, or 5 years for regulars

// 2. Show most recent IPPT score and open a new tab to calculate IPPT score
// Note b. we can use a csv or other method to avoid hard coding the IPPT score combinations

// 3. Show number of days to payday and cumulative amount earned from NS
// Note c. we need to get the rank and the exact pay amount for each month
// Note d. idea: allow user to choose rank and their pay (or enter a custom amount each month)
let themeColor: Color = Color.pink

// User Ippt Data view model
class IpptData: ObservableObject {
    //    For IPPT score tracking
    @AppStorage("ipptScore") var latestIpptScore: Int = 0
    @AppStorage("targetIpptScore") var latestTargetIpptScore: Int = 100
    
    //    For IPPT Calculator
    @AppStorage("userAge") var userAge: Int = 18
//    userPushups and userSitups contain the literal number
    @AppStorage("userPushups") var userPushups: Int = 60
    @AppStorage("userSitups") var userSitups: Int = 60
//    if userRun = 0, time taken is longest (1100s)
//    if userRun = 59, time taken is shortest (510s)
    @AppStorage("userRun") var userRun: Int = 1
}

// User view model
class UserData: ObservableObject {
//    Core user information
    @AppStorage("newUser") var isNewUser: Bool = true
    @AppStorage("userName") var userName: String?
    @AppStorage("enlistDate") var userEnlistDate: String?
    @AppStorage("ordDate") var userOrdDate: String?
    @AppStorage("serviceDuration") var userServiceDuration: Int?
//    For LeaveBlockView
    @AppStorage("leaveCount") var remainingLeave: Int = 14
    @AppStorage("offCount") var accumulatedOff: Int = 0
}

struct ContentView: View {
    @StateObject var ipptData: IpptData = IpptData()
    @StateObject var userData: UserData = UserData()
    
//    To open a default navigationView every time the app is launched
    @State var selectedView: Int? = 0
    
//    For IpptBlockView
    @State var askIppt: Bool = false
    
    
//    MARK: App Layout
    var body: some View {
//        Shows the MainView, unless the user is new then OnBoardingView is called
        MainView
            .sheet(isPresented: $userData.isNewUser, content: {
                OnBoardingView(userData: userData)
            })
            .onAppear {
                self.selectedView = 0
            }
    }
}

// MARK: NavigationView Layout
extension ContentView {
    var MainView: some View {
//        Navigation List Layout
        NavigationView {
            List {
                //                Link to homepage
                NavigationLink(tag: 0, selection: self.$selectedView) {
                    HomeView
                } label: {
                    Image(systemName: "house.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                    Text("Home")
                        .font(.title3)
                        .padding(.leading, 10)
                }
                //                Link to IPPT View
                NavigationLink(tag: 1, selection: self.$selectedView) {
                    IpptView(ipptData: ipptData)
                } label: {
                    Image(systemName: "figure.run")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                    Text("IPPT")
                        .font(.title3)
                        .padding(.leading, 10)
                }
                //                Link to Settings View
                NavigationLink(tag: 2, selection: self.$selectedView) {
                    SettingsView(userData: userData)
                } label: {
                    Image(systemName: "gear")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                    Text("Settings")
                        .font(.title3)
                        .padding(.leading, 10)
                }
            }
            .listStyle(SidebarListStyle())
            .navigationTitle("Wadio")
        }
    }
}

// MARK: UI Layout
extension ContentView {
    //    Home Layout
    var HomeView: some View {
        ZStack {
            //            Background
            Color(UIColor.secondarySystemBackground).ignoresSafeArea()
            //            Content
            ScrollView(showsIndicators: false) {
                VStack {
                    CircleGraphBlockView
                        .frame(maxWidth: 500, maxHeight: 500)
                        .padding(.top, 20)
                    HStack {
                        OrdPercentageBlockView
                            .frame(maxWidth: 245, minHeight: 105)
                        Spacer()
                        IpptBlockView
                            .frame(maxWidth: 245, minHeight: 105)
                    }
                    .frame(maxWidth: 500)
                    HStack {
                        PaydayBlockView
                            .frame(maxWidth: 245, minHeight: 105)
                        LeaveBlockView
                            .frame(maxWidth: 245, minHeight: 105)
                    }
                    .frame(maxWidth: 500)
                }
            }
            .padding(.horizontal, 20)
        }
        .navigationTitle(String("Hello \(userData.userName ?? "New User")!"))
    }
    
    //    Circle graph Layout
    private var CircleGraphBlockView: some View {
        ZStack {
            //            Background circle
            Circle()
                .stroke(
                    themeColor.opacity(0.2),
                    style: StrokeStyle(
                        lineWidth: 40
                    )
                )
                .padding(40)
            //            Main circle
            withAnimation(.spring(), { 
                Circle()
                    .trim(from: 1-calculateOrdPercent(enlistDate: userData.userEnlistDate ?? "Jun 09, 2023", ordDate: userData.userOrdDate ?? "Jun 09, 2023"), to: 1.0)
                    .stroke(
                        themeColor.opacity(0.9),
                        style: StrokeStyle(
                            lineWidth: 40,
                            lineCap: .round
                        )
                    )
                    .padding(40)
                    .rotationEffect(Angle.degrees(-90))
            })
            VStack {
                //                            If ORD date has passed, change text to "ORD LO"
                Text(calculateDaysToOrd(ordDate: userData.userOrdDate ?? "Jun 09, 2023") >= 1 ?
                     String(calculateDaysToOrd(ordDate: userData.userOrdDate ?? "Jun 09, 2023")):"ORD LO"
                )
                .font(Font.system(Font.TextStyle.largeTitle, design: Font.Design.rounded))
//                .font(Font.system(size: 55.0, weight: .semibold, design: .rounded))
                .fontWeight(.semibold)
                //                            If ORD date has passed, change text to "WHERE GOT TIME"
                Text(calculateDaysToOrd(ordDate: userData.userOrdDate ?? "Jun 09, 2023") >= 1 ? "Days to ORD":"WHERE GOT TIME")
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .font(Font.system(.headline, design: .rounded))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 25.0)
                .foregroundColor(Color(UIColor.systemBackground))
        )    
    }
    
    //    Pill shaped: ORD percentage completed
    private var OrdPercentageBlockView: some View {
        @State var OrdPercent = String(format: "%.1f", calculateOrdPercent(enlistDate: userData.userEnlistDate ?? "Jun 09, 2023", ordDate: userData.userOrdDate ?? "Jun 09, 2023") * 100)
        return pillView(pillVariable: "\(OrdPercent)%", pillName: "Completed", pillIconSymbol: "checkmark.circle.fill", pillColor: Color.green)
    }
    //    Pill shaped: IPPT recent score
    private var IpptBlockView: some View {
            //            Picker is embedded in a menu because the picker label cannot be modified
        pillView(pillVariable: String(ipptData.latestIpptScore), pillName: "IPPT",pillIconSymbol: "figure.run.circle.fill", pillColor: Color.red)
            .foregroundColor(Color(UIColor.label))
    }
    
    //     Pill shaped: Days left till next payday
    private var PaydayBlockView: some View {
        pillView(pillVariable: String(calculateDaysToPayday()), pillName: "Payday", pillIconSymbol: "creditcard.circle.fill", pillColor: Color.orange)
    }
    
    //    Pill shaped: Outstanding leave days
    private var LeaveBlockView: some View {
        pillView(pillVariable: String(userData.remainingLeave), pillName: "Leave", pillIconSymbol: "calendar.circle.fill", pillColor: Color.blue)
    }
    
}


// Basic UI for the pill shaped view in the HomeView
struct pillView: View {
    @State var pillVariable: String
    let pillName: String
    let pillIconSymbol: String
    let pillColor: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25.0)
                .foregroundColor(Color(UIColor.systemBackground))
            VStack {
                HStack {
                    // pill icon
                    ZStack {
                        Image(systemName: pillIconSymbol)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(pillColor)
                            .frame(width: 30)
                    }
                    Spacer()
                    // pill number
                    Text(pillVariable)
                        .font(Font.system(.title, design: .rounded))
                        .fontWeight(.semibold)
                } 
                Spacer()
                Text(pillName)
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
        }
    }

}

// MARK: Logic
extension ContentView {
//    Logic for CircleGraphBlockView
//    To determine the percentage completed as seen in the circular graph
    func calculateOrdPercent(enlistDate: String, ordDate: String) -> Double {
//        Convert string dates into Date data types
        let enlistTemp = DateUtilities().StringtoDate(date: enlistDate)
        let ordTemp = DateUtilities().StringtoDate(date: ordDate)
        let todayTemp = Date.now
        
//        Find the number of days between enlistment, ORD and current day to derive percentage
        let calendar = Calendar.current
        let enlistToNowDays = Double(calendar.dateComponents([.day], from: enlistTemp, to: todayTemp).day ?? 0)
        let enlistToOrdDays = Double(calendar.dateComponents([.day], from: enlistTemp, to: ordTemp).day ?? 0)
        
        return enlistToNowDays / enlistToOrdDays
    }
    
//   To determine the number of days to ORD
    func calculateDaysToOrd(ordDate: String) -> Int {
        let ordTemp = DateUtilities().StringtoDate(date: ordDate)
        let todayTemp = Date.now
        
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: todayTemp, to: ordTemp).day ?? 0
    }
    
//    To determine the number of days till the next day (ie: the 10th of every month) from the current date
    
    func calculateDaysToPayday() -> Int {
//        Target date: 10th of the month
        let calendar = Calendar.current
        
        // Get the current date
        let currentDate = Date()

        // Get the current month and year
        let currentComponents = calendar.dateComponents([.year, .month], from: currentDate)
        let currentYear = currentComponents.year ?? 0
        let currentMonth = currentComponents.month ?? 0
        
        // Create a date representing the 10th of the current month
        var targetComponents = DateComponents()
        targetComponents.year = currentYear
        targetComponents.month = currentMonth
        targetComponents.day = 10
        let targetDate = calendar.date(from: targetComponents)
        
        // Calculate the difference in days between the current date and the 10th of the month
        if let targetDate = targetDate {
            let daysDifference = calendar.dateComponents([.day], from: currentDate, to: targetDate).day ?? 0
            
            if daysDifference >= 0 {
                let daysLeft = daysDifference
                return daysLeft
            } else {
                // Calculate the number of days left until the 10th of the next month
                var nextMonthComponents = DateComponents()
                nextMonthComponents.year = currentYear
                nextMonthComponents.month = currentMonth + 1
                nextMonthComponents.day = 10
                if let nextMonthDate = calendar.date(from: nextMonthComponents) {
                    let daysLeft = calendar.dateComponents([.day], from: currentDate, to: nextMonthDate).day ?? 0
                    return daysLeft
                } else {
                    return 0
                }
            }
        }
        return 0
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}


