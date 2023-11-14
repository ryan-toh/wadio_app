import SwiftUI

// MARK: Layout
struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
//    Allows settings to change entered user data
    @ObservedObject var userData: UserData
    
//    For SettingsResetLeaveView
    @State var showEditEnlistDate: Bool = false
    @State var newEnlistDate: Date = Date.now
    @State var newServiceTerm: Int = 22
    
    var body: some View {
        ZStack {
            Color(UIColor.secondarySystemBackground).ignoresSafeArea(.all)
                VStack {
                    List {
//                        Edit the name that appears on the HomeView if needed
                        Section(header: Text("Personalise"), footer: Text("Edit your name by tapping on it.")) {
                            SettingsNameView
                        }
                        Section(header: Text("Leave")) {
                            SettingsLeaveView
                            SettingsOffView
                            SettingsResetLeaveView
                        }
                        // Shows the Enlistment, ORD Dates, as well as a button to change the enlistment date if required
                        Section(header: Text("Dates")) {
                            HStack {
                                Text("Enlist Date")
                                Spacer()
                                Text(userData.userEnlistDate ?? "Error")
                            }
                            HStack {
                                Text("ORD Date")
                                Spacer()
                                Text(userData.userOrdDate ?? "Error")
                            }
                            Button(action: {
                                showEditEnlistDate.toggle()
                            }, label: {
                                Text("Edit Dates")
                            })
                            .sheet(isPresented: $showEditEnlistDate, content: {
                                EditEnlistDateView
                            })
                        }
                        Section(header: Text("Reset")) {
                            SettingsResetView
                        }
                        Section(header: Text("About")) {
                            NavigationLink("Acknowledgements") { 
                                SettingsAboutView
                            }
                        }
                    }
                    Spacer()
                }
                .frame(maxWidth: 500)
                .navigationTitle("Settings")
                    
        }
    }
}

// MARK: UI
extension SettingsView {
//    Change username here
    var SettingsNameView: some View {
        TextField("Enter your name", text: $userData.userName.toUnwrapped(defaultValue: ""))
    }
    
//    Edit remaining leave count
    var SettingsLeaveView: some View {
        Stepper(value: $userData.remainingLeave, in: 0...14, step: 1) { 
            HStack {
                Text("Remaining Leave")
                Spacer()
                Text(String(userData.remainingLeave))
                    .foregroundColor(.accentColor)
                    .fontWeight(.semibold)
            }
        } 
    }
    
//    Edit accumulated off count
    var SettingsOffView: some View {
        Stepper(value: $userData.accumulatedOff, in: 0...((userData.userServiceDuration ?? 22) * 30), step: 1) { 
            HStack {
                Text("Accumulated Off")
                Spacer()
                Text(String(userData.accumulatedOff))
                    .foregroundColor(.accentColor)
                    .fontWeight(.semibold)
            }
        } 
    }
    
//    Reset the amount of leave remaining
    var SettingsResetLeaveView: some View {
        Button(action: {
            userData.remainingLeave = 14
        }, label: {
            Text("Reset Leave")
        })
    }
    
//    Acknowledgements
    var SettingsAboutView: some View {
        ZStack {
            Color(UIColor.secondarySystemBackground).ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Built by Ryan on 21-06-23")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HStack {
                        Image(systemName: "swift")
                        Text("Playgrounds 4.3.1")
                            .font(.headline)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 10.0, style: .continuous)
                        .foregroundColor(Color(UIColor.systemBackground))
                )
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Acknowledgements")
    }
    
//      Nuke button (aka reset and restart onboarding
    var SettingsResetView: some View {
        Button {
            userData.isNewUser = true
        } label: {
            Text("Reset")
        }

    }
    
//    UI for changing the enlistment date (appears as a sheet)
    var EditEnlistDateView: some View {
        ZStack {
            Color(UIColor.secondarySystemBackground).ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                Spacer()
                Text("Edit Enlistment Date")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)
                Text("Select 22 months if you passed your IPPT.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)
                Picker(selection: $newServiceTerm) { 
                    Text("22 months").tag(22)
                    Text("24 months").tag(24)
                } label: { 
                    Text("Service Term")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.bottom, 10)
                DatePicker("ORD Date", selection: $newEnlistDate, in: ...Date(), displayedComponents: [.date])
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                    .background(Color.primary.colorInvert())
                    .cornerRadius(10.0)
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 3, y: 8)
                    .padding(10)
                    .padding(.bottom, 10)
                Spacer()
                Button(action: {
                    //                Advance to the next section
                    updateOrdDate()
                }, label: {
                    Text("OK")
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
                    showEditEnlistDate = false
                }, label: {
                    Text("Cancel")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                })
                
            }
            .padding(20)
        }
    }
}

// MARK: LOGIC
// Allows you to unwrap a optional value by providing a default value 
extension SettingsView {
    func updateOrdDate() {
        guard let ordDateTemp = Calendar.current.date(byAdding: .month, value: newServiceTerm, to: newEnlistDate) else {
            return
        }
        userData.userEnlistDate = DateUtilities().dateToString(date: newEnlistDate)
        userData.userOrdDate = DateUtilities().dateToString(date: ordDateTemp)
        showEditEnlistDate = false
    }
}

extension Binding {
    func toUnwrapped<T>(defaultValue: T) -> Binding<T> where Value == Optional<T> {
        Binding<T>(get: {self.wrappedValue ?? defaultValue}, set: {self.wrappedValue = $0})
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(userData: UserData())
    }
}
