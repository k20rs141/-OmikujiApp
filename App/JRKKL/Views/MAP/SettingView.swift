import SwiftUI

struct SettingView: View {
    @Environment(\.dismiss) private var dismiss
    var locationManager: LocationManager
    @State private var presentAlert = false
    @State private var isModalSheet = false
    // マップの種類
    @Binding var mapConfiguration: String
    // 通知を知らせる範囲
    @State private var geoDistance = 100
    @State private var inputNumber = 100
    // 通知回数
    @State private var notificationCount = 1
    // 通知間隔
    @State private var notificationTime = 2
    // 追跡設定
    @State private var trackingModes = "位置情報追跡"
    // 音声案内
    @State private var isSpeechGuide = false
    @State private var title = 0
    @State private var batteryAlert = false
    @State private var explanationView = false
    
    let screen = UIScreen.main.bounds
    let numberLimit = 9999
    let mapType = ["Standard", "Hybrid", "Imagery"]
    let trackingType = ["バッテリー節約", "位置情報追跡"]
    
    var body: some View {
        ZStack {
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
                        ForEach(locationManager.information, id: \.id) { item in
                            switch item.id {
                            case 0:
                                HStack {
                                    SetupItem(explanationView: $explanationView, title: $title, id: item.id, text: "マップの種類")
                                    Spacer()
                                    Button {
                                        title = item.id
                                        isModalSheet = true
                                    } label: {
                                        Text("\(mapConfiguration)")
                                            .textStyle()
                                    }
                                    .tag(title)
                                }
                                .cardStyle()
                            case 1:
                                HStack {
                                    SetupItem(explanationView: $explanationView, title: $title, id: item.id, text: "通知範囲")
                                    Button {
                                        title = item.id
                                        presentAlert = true
                                    } label: {
                                        Text("\(geoDistance)m")
                                            .textStyle()
                                    }
                                    .alert("通知範囲", isPresented: $presentAlert, actions: {
                                        TextField("100", value: $inputNumber, format: .number)
                                            .keyboardType(.numberPad)
                                            .foregroundColor(.primary)
                                        Button("OK", action: {
                                            //最大範囲を9999mに制限
                                            if inputNumber > numberLimit {
                                                inputNumber = numberLimit
                                            }
                                            UserDefaults.standard.set(inputNumber, forKey: "geoDistance")
                                            geoDistance = inputNumber
                                            print("\(geoDistance)m")
                                            locationManager.geoDistance = geoDistance
                                        })
                                        Button("Cancel", role: .cancel, action: {
                                        })
                                    }, message: {
                                        Text("通知を知らせる範囲を\n指定してください。")
                                    })
                                }
                                .cardStyle()
                            case 2:
                                HStack {
                                    SetupItem(explanationView: $explanationView, title: $title, id: item.id, text: "通知回数")
                                    Button {
                                        title = item.id
                                        isModalSheet = true
                                    } label: {
                                        Text("\(notificationCount)回")
                                            .textStyle()
                                    }
                                    .tag(title)
                                }
                                .cardStyle()
                            case 3:
                                HStack {
                                    SetupItem(explanationView: $explanationView, title: $title, id: item.id, text: "通知間隔")
                                    Button {
                                        title = item.id
                                        isModalSheet = true
                                    } label: {
                                        Text("\(notificationTime)秒")
                                            .textStyle()
                                    }
                                    .tag(title)
                                }
                                .cardStyle()
                            case 4:
                                HStack {
                                    SetupItem(explanationView: $explanationView, title: $title, id: item.id, text: "追跡設定")
                                    Button {
                                        title = item.id
                                        isModalSheet = true
                                    } label: {
                                        Text("\(trackingModes)")
                                            .textStyle()
                                    }
                                    .tag(title)
                                    .alert("", isPresented: $batteryAlert, actions: {}, message: {
                                        Text("バッテリー節約モードに変更すると\n通知が遅れる可能性があります。")
                                    })
                                }
                                .cardStyle()
                            case 5:
                                HStack {
                                    SetupItem(explanationView: $explanationView, title: $title, id: item.id, text: "音声案内")
                                    Toggle("", isOn: $isSpeechGuide)
                                        .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.227, green: 0.235, blue: 0.278)))
                                        .onChange(of: isSpeechGuide) {
                                            UserDefaults.standard.set(isSpeechGuide, forKey: "isSpeechGuide")
                                            if isSpeechGuide {
                                                locationManager.isSpeechGuide = true
                                            } else {
                                                locationManager.isSpeechGuide = false
                                            }
                                        }
                                }
                                .cardStyle()
                            default:
                                Text("failted")
                            }
                        }
                    }
                    .padding(.top)
                }
                .frame(width: screen.width * 0.9, height: screen.height * 0.75, alignment: .top)
            }
            .onAppear {
                let geoDistance = UserDefaults.standard.integer(forKey: "geoDistance")
                let notificationCount = UserDefaults.standard.integer(forKey: "notificationCount")
                let notificationTime = UserDefaults.standard.integer(forKey: "notificationTime")
                let trackingModes = UserDefaults.standard.string(forKey: "trackingModes") ?? "位置情報追跡"
                let isSpeechGuide = UserDefaults.standard.bool(forKey: "isSpeechGuide")
                self.geoDistance = geoDistance
                self.notificationCount = notificationCount
                self.notificationTime = notificationTime
                self.trackingModes = trackingModes
                self.isSpeechGuide = isSpeechGuide
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundColor(.black)
            .background(.white)
            .ignoresSafeArea()
            .sheet(isPresented: $isModalSheet) {
                PickerView()
                    .presentationDetents([.fraction(0.28)])
                    .onDisappear {
                        if title == 4 && trackingModes == "バッテリー節約" {
                            batteryAlert = true
                        }
                    }
            }
            // explanationViewViewが選択された時に背景をグレーにするためのView
            VStack {
                EmptyView()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(explanationView ? .black.opacity(0.5) : .clear)
            ExplanationView(locationManager: locationManager, explanationView: $explanationView, title: $title)
                .opacity(explanationView ? 1 : 0)
                .scaleEffect(explanationView ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: explanationView)
        }
    }
    
    @ViewBuilder
    func PickerView() -> some View {
        HStack {
            Spacer()
            Button(action: {
                switch title {
                case 0:
                    UserDefaults.standard.set(mapConfiguration, forKey: "mapConfiguration")
                case 2:
                    UserDefaults.standard.set(notificationCount, forKey: "notificationCount")
                    locationManager.notificationCount = notificationCount
                case 3:
                    UserDefaults.standard.set(notificationTime, forKey: "notificationTime")
                    locationManager.notificationTime = notificationTime
                case 4:
                    UserDefaults.standard.set(trackingModes, forKey: "trackingModes")
                    locationManager.trackingModes = trackingModes
                    locationManager.locationAccuracy()
                default:
                    break
                }
                UserDefaults.standard.removeObject(forKey: "trackingMode")
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
        case 2:
            Picker("", selection: $notificationCount) {
                ForEach(1 ... 50, id: \.self) { number in
                    Text("\(number)回")
                        .tag(number)
                }
            }
            .pickerStyle(.wheel)
        case 3:
            Picker("", selection: $notificationTime) {
                ForEach(2 ... 10, id: \.self) { number in
                    Text("\(number)秒")
                        .tag(number)
                }
            }
            .pickerStyle(.wheel)
        case 4:
            Picker("", selection: $trackingModes) {
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
    @Binding var explanationView: Bool
    @Binding var title: Int
    
    var id: Int
    var text: String
    
    var body:some View {
        Text(text)
            .font(.title3)
            .fontWeight(.bold)
        Button {
            explanationView = true
            title = id
        } label: {
            Image(systemName: "questionmark.circle")
                .foregroundColor(.gray)
                .font(.title2)
        }
        Spacer()
    }
}


#Preview {
    SettingView(locationManager: LocationManager(), mapConfiguration: .constant("Standard"))
}
