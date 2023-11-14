import SwiftUI

struct OnBoardingView: View {
    //     To save user data into UserData view model
    @ObservedObject var userData: UserData
    
    //    Indicate step in the onboarding process
    @State var onBoardingStep: Int = 0
    
    //    Needed to dismiss the onboarding window
    @Environment(\.presentationMode) var presentationMode
    
    //    Collect information during onboarding
    @State var onBoardingName: String = ""
    @State var onBoardingEnlistDate: Date = Date.now
    @State var onBoardingServiceTerm: Int = 22
    
    //    Check for errors
    @State var nameInputError: Bool = false
    
    //    Loading symbol before next view
    @State var isLoading: Bool = false
    
//    MARK: Layout
    var body: some View {
        ZStack {
            //            Background
            themeColor.opacity(0.1).ignoresSafeArea()
            //            Content
            switch onBoardingStep {
            case 0:
                welcomeSection
            case 1:
                addNameSection
            case 2:
                addEnlistDateSection
            default:
                VStack {
                    Spacer()
                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                        .foregroundColor(Color.yellow)
                    Text("There was an error.")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                    Spacer()
                    Button(action: {
                        withAnimation(.linear) { 
                            onBoardingStep = 0
                        }
                    }, label: {
                        Text("Reset")
                            .fontWeight(.semibold)
                    })
                }
                .padding()
            }
            
        }
        .interactiveDismissDisabled()
    }
    
//    MARK: UI Views
    //    Welcome page
    private var welcomeSection: some View {
        VStack(alignment: .leading) {
            Spacer()
            Image("ord_app_icon_v2")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .cornerRadius(10.0, antialiased: true)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 5.0, y: 15.0)
                .padding(.bottom, 30)
            Text("Welcome to Wadio! ✌️")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.bottom, 10)
            Text("We just need a few details from you so that we can set up your app correctly.")
            Spacer()
            Button(action: {
                //                Advance to the next section
                verifyInfoAdvanceNextView()
            }, label: {
                if isLoading {
                    ProgressView()
                        .fontWeight(.semibold)
                        .foregroundColor(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(
                            RoundedRectangle(cornerRadius: 10.0, style: .continuous)
                        )
                }
                else {
                    Text("Continue")
                        .fontWeight(.semibold)
                        .foregroundColor(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(
                            RoundedRectangle(cornerRadius: 10.0, style: .continuous)
                        )   
                }
            })
            .accentColor(themeColor)
        }
        .padding(30)
    }
    
    //    Request user name
    private var addNameSection: some View {
        VStack(alignment: .leading) {
            Spacer()
            Text("🤔")
                .font(.largeTitle)
                .padding(.bottom, 5)
            Text("What is your name?")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.bottom, 10)
            Text("So that we can say hi to you when you launch the app.")
                .padding(.bottom, 10)
            TextField("Name", text: $onBoardingName)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10.0, style: .continuous)
                        .foregroundColor(Color.white)
                )
                .padding(.bottom, 10)
            if nameInputError {
                Text("Please input your name.")
                    .foregroundColor(Color.red)
            }
            Spacer()
            Button(action: {
                //                Advance to the next section
                verifyInfoAdvanceNextView()
            }, label: {
                Text("Next")
                    .fontWeight(.semibold)
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(
                        RoundedRectangle(cornerRadius: 10.0, style: .continuous)
                    )
            })
            .accentColor(themeColor)
            //            Button to go back to the previous onboarding screen if needed
            Button(action: {
                returnPreviousView()
            }, label: {
                Text("Back")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
            })
            
        }
        .padding(30)
    }
    
    //    Request user enlistment date    
    private var addEnlistDateSection: some View {
        VStack(alignment: .leading) {
            Spacer()
            Text("Enter enlistment date")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.bottom, 10)
            Text("Select 22 months if you passed your IPPT.")
                .padding(.bottom, 5)
            Text("If you are enlisting today, simply hit continue.")
                .padding(.bottom, 10)
            Picker(selection: $onBoardingServiceTerm) { 
                Text("22 months").tag(22)
                Text("24 months").tag(24)
            } label: { 
                Text("Service Term")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.bottom, 10)
            DatePicker("ORD Date", selection: $onBoardingEnlistDate, in: ...Date(), displayedComponents: [.date])
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                .background(Color.primary.colorInvert())
                .cornerRadius(10.0)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 5.0, y: 15.0)
                .padding(.bottom, 10)
            Spacer()
            Button(action: {
                //                Advance to the next section
                verifyInfoAdvanceNextView()
            }, label: {
                Text("I'm Done")
                    .fontWeight(.semibold)
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(
                        RoundedRectangle(cornerRadius: 10.0, style: .continuous)
                    )
            })
            .accentColor(themeColor)
            Button(action: {
                returnPreviousView()
            }, label: {
                Text("Back")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
            })
            
        }
        .padding(30)
    }
}

// MARK: Functions
extension OnBoardingView {
//    Return to the previous page of the onboarding if needed
    private func returnPreviousView() {
//        If the button somehow glitches into the first view, return to the first page (exception handling)
        if onBoardingStep == 0 {
            onBoardingStep = 0
        } else {
            withAnimation(.spring(response: 0.2)) { 
                onBoardingStep -= 1
            }
        }
    }
    
//    Check that the required information has been entered and enter the next page
    private func verifyInfoAdvanceNextView() {
        switch onBoardingStep {
        case 1:
            if onBoardingName.count < 2 {
                nameInputError = true
                return
            } default:
            break
        }        
//        Onboard user if all the onboarding steps has been completed
        if onBoardingStep == 2 {
            onBoardUser()            
        } else {
            withAnimation(.spring(response: 0.2)) { 
                onBoardingStep += 1
            }
        }
    }
    
//    Save the data to AppStorage and close the sheet
    private func onBoardUser() {
//        determine the ORD date by adding 22 or 24 months to enlist date, depending on user selection
        let ordDateTemp = Calendar.current.date(byAdding: .month, value: onBoardingServiceTerm, to: onBoardingEnlistDate) ?? onBoardingEnlistDate
        
//        save the new details to AppStorage
        userData.userName = onBoardingName
        userData.userServiceDuration = onBoardingServiceTerm
//        dates are saved in strings, due to lack of native Date support in appstorage [date is converted to string using dateToString]
        userData.userEnlistDate = DateUtilities().dateToString(date: onBoardingEnlistDate)
        userData.userOrdDate = DateUtilities().dateToString(date: ordDateTemp)
        
//        Set isNewUser to false
        userData.isNewUser = false
        
//        Close the onboarding sheet
        presentationMode.wrappedValue.dismiss()
    }
}

struct OnBoardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnBoardingView(userData: UserData())
    }
}
