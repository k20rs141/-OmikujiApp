import Combine
import SwiftUI

struct SettingView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var locationManager: LocationManager
    @State private var presentAlert = false
    @State private var isSpeechGuide = false
    @State private var isModalSheet = false
    // マップの種類
    @Binding var mapConfiguration: String
    // 通知を知らせる範囲
    @State private var geoDistance = "200"
    @State private var bufText = ""
    // 通知回数
    @State private var notificationCount = 1
    // 通知間隔
    @State private var notificationTime = 2
    // 追跡設定
    @State private var trackingMode = "位置情報追跡"
    // 音声案内
    @State private var title = 0
    
    let screen = UIScreen.main.bounds
    let mapInfomation = [0, 1, 2, 3, 4, 5]
    let numberLimit = 5
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .padding()
                        .background(.ultraThickMaterial)
                        .clipShape(Circle())
                }
                Text("マップ設定")
                    .font(.largeTitle)
                Spacer()
            }
            .padding()
            ScrollView {
                VStack(spacing: 13) {
                    HStack {
                        Text("マップの種類")
                        Button {
                            
                        } label: {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.gray)
                                .font(.title2)
                        }
                        Spacer()
                        Button {
                            title = 0
                            isModalSheet = true
                        } label: {
                            Text("\(mapConfiguration)")
                                .foregroundColor(.gray)
                                .frame(width: screen.width * 0.25, height: screen.height * 0.07, alignment: .trailing)
                        }
                    }
                    .padding()
                    .frame(width: screen.width * 0.9, height: screen.height * 0.075)
                    .background(Color("PopUpViewColor"))
                    .cornerRadius(13)
                    HStack {
                        Text("通知範囲")
                        Button {
                            
                        } label: {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.gray)
                                .font(.title2)
                        }
                        Spacer()
                        Button {
                            presentAlert = true
                        } label: {
                            Text("\(geoDistance)m")
                                .foregroundColor(.gray)
                                .frame(width: screen.width * 0.25, height: screen.height * 0.07, alignment: .trailing)
                            //                                .background(.orange)
                        }
                        .alert("通知範囲", isPresented: $presentAlert, actions: {
                            TextField("100", text: $bufText)
                                .keyboardType(.numberPad)
                            Button("OK", action: {
                                //最大文字数を５桁までに制限
                                if bufText.count > numberLimit {
                                    bufText = String(bufText.prefix(numberLimit))
                                }
                                UserDefaults.standard.set(bufText, forKey: "geoDistance")
                                geoDistance = bufText
                                self.bufText = ""
                                print("\(geoDistance)m")
                                locationManager.changeGeoDistance(radius: Int(geoDistance) ?? 0)
                            })
                            Button("Cancel", role: .cancel, action: {
                            })
                        }, message: {
                            Text("通知を知らせる範囲を\n指定してください。")
                        })
                    }
                    .padding()
                    .frame(width: screen.width * 0.9, height: screen.height * 0.075)
                    .background(Color("PopUpViewColor"))
                    .cornerRadius(13)
                    HStack {
                        Text("通知回数")
                        Button {
                            
                        } label: {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.gray)
                                .font(.title2)
                        }
                        Spacer()
                        Button {
                            title = 1
                            isModalSheet = true
                        } label: {
                            Text("\(notificationCount)回")
                                .foregroundColor(.gray)
                                .frame(width: screen.width * 0.25, height: screen.height * 0.07, alignment: .trailing)
                        }
                    }
                    .padding()
                    .frame(width: screen.width * 0.9, height: screen.height * 0.075)
                    .background(Color("PopUpViewColor"))
                    .cornerRadius(13)
                    HStack {
                        Text("通知間隔")
                        Button {
                            
                        } label: {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.gray)
                                .font(.title2)
                        }
                        Spacer()
                        Button {
                            title = 2
                            isModalSheet = true
                        } label: {
                            Text("\(notificationTime)秒")
                                .foregroundColor(.gray)
                                .frame(width: screen.width * 0.25, height: screen.height * 0.07, alignment: .trailing)
                        }
                    }
                    .padding()
                    .frame(width: screen.width * 0.9, height: screen.height * 0.075)
                    .background(Color("PopUpViewColor"))
                    .cornerRadius(13)
                    HStack {
                        Text("追跡設定")
                        Button {
                            
                        } label: {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.gray)
                                .font(.title2)
                        }
                        Spacer()
                        Button {
                            title = 3
                            isModalSheet = true
                        } label: {
                            Text("\(trackingMode)")
                                .foregroundColor(.gray)
                                .frame(width: screen.width * 0.33, height: screen.height * 0.07, alignment: .trailing)
                        }
                    }
                    .padding()
                    .frame(width: screen.width * 0.9, height: screen.height * 0.075)
                    .background(Color("PopUpViewColor"))
                    .cornerRadius(13)
                    HStack {
                        Text("音声案内")
                        Button {
                            
                        } label: {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.gray)
                                .font(.title2)
                        }
                        Spacer()
                        Button {
                            isSpeechGuide.toggle()
                            UserDefaults.standard.set(isSpeechGuide, forKey: "isSpeechGuide")
                        } label: {
                            Toggle("", isOn: $isSpeechGuide)
                                .toggleStyle(SwitchToggleStyle(tint: Color.gray))
                        }
                        .onChange(of: isSpeechGuide) { newValue in
                            if isSpeechGuide {
                                locationManager.changeSpeechGuide(announce: true)
                            } else {
                                locationManager.changeSpeechGuide(announce: false)
                            }
                        }
                    }
                    .padding()
                    .frame(width: screen.width * 0.9, height: screen.height * 0.07)
                    .background(Color("PopUpViewColor"))
                    .cornerRadius(13)
                }
                .padding(.top)
            }
            .frame(width: screen.width * 0.9, height: screen.height * 0.75, alignment: .top)
        }
        .onAppear {
            let geoDistance = UserDefaults.standard.string(forKey: "geoDistance") ?? "0"
            let notificationCount = UserDefaults.standard.integer(forKey: "notificationCount")
            let notificationTime = UserDefaults.standard.integer(forKey: "notificationTime")
            let trackingMode = UserDefaults.standard.string(forKey: "trackingMode") ?? "Default"
            let isSpeechGuide = UserDefaults.standard.bool(forKey: "isSpeechGuide")
            self.geoDistance = geoDistance
            self.notificationCount = notificationCount
            self.notificationTime = notificationTime
            self.trackingMode = trackingMode
            self.isSpeechGuide = isSpeechGuide
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundColor(.black)
        .background(.white)
        .ignoresSafeArea()
        .sheet(isPresented: $isModalSheet) {
            PickerView(locationManager: locationManager, isModalSheet: $isModalSheet, mapConfiguration: $mapConfiguration, notificationCount: $notificationCount, notificationTime: $notificationTime, trackingMode: $trackingMode, title: $title)
                .presentationDetents([.fraction(0.28)])
        }
    }
}

struct PickerView: View {
    @ObservedObject var locationManager: LocationManager
    @Binding var isModalSheet: Bool
    @Binding var mapConfiguration: String
    @Binding var notificationCount: Int
    @Binding var notificationTime: Int
    @Binding var trackingMode: String
    @Binding var title: Int
    
    let screen = UIScreen.main.bounds
    let mapType = ["Standard", "Hybrid", "Imagery"]
    let trackingType = ["バッテリー節約", "位置情報追跡"]
    
    var body: some View {
        HStack {
            Button(action: {
                isModalSheet = false
            }) {
                Text("キャンセル")
                    .foregroundColor(.gray)
            }
            Spacer()
            Button(action: {
                UserDefaults.standard.set(mapConfiguration, forKey: "mapConfiguration")
                UserDefaults.standard.set(notificationCount, forKey: "notificationCount")
                UserDefaults.standard.set(notificationTime, forKey: "notificationTime")
                UserDefaults.standard.set(trackingMode, forKey: "trackingMode")
                locationManager.changeNotificationCount(count: notificationCount)
                locationManager.changeNotificationTimer(interval: notificationTime)
                isModalSheet = false
            }) {
                Text("完了")
            }
        }
        .foregroundColor(.primary)
        .padding(.horizontal)
        .frame(width: screen.width * 0.95, height: screen.height * 0.05)
        .padding()
        switch title {
        case 0:
            Picker("", selection: $mapConfiguration) {
                ForEach(mapType, id: \.self) { type in
                    Text("\(type)")
                        .tag(type)
                }
            }
            .pickerStyle(.wheel)
        case 1:
            Picker("", selection: $notificationCount) {
                ForEach(1 ... 50, id: \.self) { number in
                    Text("\(number)回")
                        .tag(number)
                }
            }
            .pickerStyle(.wheel)
        case 2:
            Picker("", selection: $notificationTime) {
                ForEach(2 ... 10, id: \.self) { number in
                    Text("\(number)秒")
                        .tag(number)
                }
            }
            .pickerStyle(.wheel)
        case 3:
            Picker("", selection: $trackingMode) {
                ForEach(trackingType, id: \.self) { type in
                    Text("\(type)")
                        .tag(type)
                }
            }
            .pickerStyle(.wheel)
        default:
            Text("default")
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView(locationManager: LocationManager(), mapConfiguration: .constant("standard"))
    }
}
