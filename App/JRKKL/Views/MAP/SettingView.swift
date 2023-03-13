import Combine
import SwiftUI

struct SettingView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var locationManager: LocationManager
    @State private var presentAlert = false
    @State private var isModalSheet = false
    // マップの種類
    @Binding var mapConfiguration: String
    // 通知を知らせる範囲
    @State private var geoDistance = "100"
    @State private var bufText = ""
    // 通知回数
    @State private var notificationCount = 1
    // 通知間隔
    @State private var notificationTime = 2
    // 追跡設定
    @State private var trackingMode = "位置情報追跡"
    // 音声案内
    @State private var isSpeechGuide = false
    @State private var title = 0
    
    let screen = UIScreen.main.bounds
    let numberLimit = 5
    let mapType = ["Standard", "Hybrid", "Imagery"]
    let trackingType = ["バッテリー節約", "位置情報追跡"]
    
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
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()
            ScrollView {
                VStack(spacing: 13) {
                    HStack {
                        SetupItem(text: "マップの種類")
                        Spacer()
                        Button {
                            title = 0
                            print(title)
                            isModalSheet = true
                        } label: {
                            Text("\(mapConfiguration)")
                                .textStyle()
                        }.tag(title)
                    }
                    .cardStyle()
                    HStack {
                        SetupItem(text: "通知範囲")
                        Button {
                            presentAlert = true
                        } label: {
                            Text("\(geoDistance)m")
                                .textStyle()
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
                    .cardStyle()
                    HStack {
                        SetupItem(text: "通知回数")
                        Button {
                            title = 1
                            print(title)
                            isModalSheet = true
                        } label: {
                            Text("\(notificationCount)回")
                                .textStyle()
                        }.tag(title)
                    }
                    .cardStyle()
                    HStack {
                        SetupItem(text: "通知間隔")
                        Button {
                            title = 2
                            print(title)
                            isModalSheet = true
                        } label: {
                            Text("\(notificationTime)秒")
                                .textStyle()
                        }.tag(title)
                    }
                    .cardStyle()
                    HStack {
                        SetupItem(text: "追跡設定")
                        Button {
                            title = 3
                            print(title)
                            isModalSheet = true
                        } label: {
                            Text("\(trackingMode)")
                                .textStyle()
                        }.tag(title)
                    }
                    .cardStyle()
                    HStack {
                        SetupItem(text: "音声案内")
                        Toggle("", isOn: $isSpeechGuide)
                            .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.227, green: 0.235, blue: 0.278)))
                            .onChange(of: isSpeechGuide) { _ in
                                UserDefaults.standard.set(isSpeechGuide, forKey: "isSpeechGuide")
                                if isSpeechGuide {
                                    locationManager.changeSpeechGuide(announce: true)
                                } else {
                                    locationManager.changeSpeechGuide(announce: false)
                            }
                        }
                    }
                    .cardStyle()
                }
                .padding(.top)
            }
            .frame(width: screen.width * 0.9, height: screen.height * 0.75, alignment: .top)
        }
        .onAppear {
            let geoDistance = UserDefaults.standard.string(forKey: "geoDistance") ?? "100"
            let notificationCount = UserDefaults.standard.integer(forKey: "notificationCount")
            let notificationTime = UserDefaults.standard.integer(forKey: "notificationTime")
            let trackingMode = UserDefaults.standard.string(forKey: "trackingMode") ?? "位置情報追跡"
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
            PickerView()
                .presentationDetents([.fraction(0.28)])
        }
    }
    
    @ViewBuilder
    func PickerView() -> some View {
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

struct SetupItem: View {
    var text: String
    
    var body:some View {
        Text(text)
            .font(.title3)
            .fontWeight(.bold)
        Button {
            
        } label: {
            Image(systemName: "questionmark.circle")
                .foregroundColor(.gray)
                .font(.title2)
        }
        Spacer()
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView(locationManager: LocationManager(), mapConfiguration: .constant("standard"))
    }
}
