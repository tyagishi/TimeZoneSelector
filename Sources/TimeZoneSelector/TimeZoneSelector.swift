//
//  TimeZoneSelector.swift
//
//  Created by : Tomoaki Yagishita on 2020/11/19
//  © 2020  SmallDeskSoftware
//

import SwiftUI
import SwiftUIColorNames

public typealias TZCompletion = (TimeZone) -> Void

public struct TimeZoneRegionSelector: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var isPresented: Bool
    @Binding var selectedTimeZone: TimeZone?
    @State private var localSelectedTZ:TimeZone? = nil
    @State private var searchString: String = ""
    
    @State private var tzSelectionType: String = "abbreviation"
    
    @State private var selectedTimeZoneWithAbbrev:String = ""
    
    let completion:TZCompletion?
    
    
    public init(isPresented: Binding<Bool>,_ selectedTimeZone: Binding<TimeZone?>,_ completion:TZCompletion? = nil) {
        self._isPresented = isPresented
        self._selectedTimeZone = selectedTimeZone
        self.completion = completion
    }
    
    public var body: some View {
        VStack {
            Picker("timezone type", selection: $tzSelectionType) {
                Text("Abbrev (ex: JST)").tag("abbreviation")
                Text("ID (ex: Asia/Tokyo)").tag("identifier")
                Text("search").tag("search")
            }
            .pickerStyle(SegmentedPickerStyle())
            if tzSelectionType == "search" {
                TextField("search keyword", text: $searchString)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.alphabet)
            }

            if tzSelectionType == "identifier" {
                List {
                    ForEach( TimeZone.regionList, id: \.self ) { region in
                        NavigationLink(region, destination: TimeZoneDetailSelector( selectedTimeZone: $localSelectedTZ, selectedRegion: region))
                    }
                }
            } else if tzSelectionType == "abbreviation" {
                List {
                    ForEach(TimeZone.abbrevList, id:\.self) { key in
                        Text(key)
                            .onTapGesture {
                                if let newTimeZone = TimeZone.init(abbreviation: key) {
                                    selectedTimeZone = newTimeZone
                                    completion?(newTimeZone)
                                    isPresented = false
                                }
                            }
                    }
                }
            } else {
                List {
                    if searchString == "" {
                        Text("")
                        Text("type keyword to filter TimeZone")
                        Text("")
                    } else {
                        ForEach( TimeZone.relatedZoneList(key: searchString), id:\.self) { region in
                            Text(region)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .onTapGesture {
                                    if let selected = TimeZone.init(identifier: region) {
                                        selectedTimeZone = selected
                                        self.presentationMode.wrappedValue.dismiss()
                                        completion?(selected)
                                        isPresented = false
                                    }
                                }
                        }
                    }
                }
            }
            
        }
        .padding()
        .background(Color.Darkturquoise)
        .onAppear {
            if let localSelectedTZ = localSelectedTZ {
                selectedTimeZone = localSelectedTZ
                completion?(localSelectedTZ)
                isPresented = false
            }
        }
        .navigationBarTitle("select timezone")
        .modifier(BarTitleModifier())
    }
}

struct BarTitleModifier: ViewModifier {
    typealias Body = NavigationView
    func body(content: Content) -> some View {
        if #available(iOS 14, *) {
            return AnyView(content.navigationBarTitleDisplayMode(.inline))
        } else {
            return AnyView(content)
        }
    }
}


struct TimeZoneDetailSelector: View {
    @Binding var selectedTimeZone: TimeZone?
    @Environment(\.presentationMode) var presentationMode
    let selectedRegion: String
    var body: some View {
        List( TimeZone.regionDetailList(region: selectedRegion), id:\.self) { detail in
            Text(detail)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onTapGesture {
                    selectedTimeZone = TimeZone.init(identifier: detail)!
                    self.presentationMode.wrappedValue.dismiss()
                }
        }
        .environment(\.editMode, .constant(.active))
    }
}

struct TimeZoneSelector_Previews: PreviewProvider {
    static var previews: some View {
        TimeZoneRegionSelector(isPresented: .constant(true), .constant(TimeZone.current))
    }
}
