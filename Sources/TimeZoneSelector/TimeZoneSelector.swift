//
//  TimeZoneSelector.swift
//
//  Created by : Tomoaki Yagishita on 2020/11/19
//  © 2020  SmallDeskSoftware
//

import SwiftUI
import SwiftUIDebugUtil

public struct TimeZoneRegionSelector: View {
    @Environment(\.presentationMode) var presentationMode

    @Binding var selectedTimeZone: TimeZone?
    @State private var localSelectedTZ:TimeZone? = nil
    @State private var searchString: String = ""
    
    @State private var tzSelectionType: String = "abbreviation"
    
    @State private var selectedTimeZoneWithAbbrev:String = ""
    
    init(_ selectedTimeZone:TimeZone?) {
        self._selectedTimeZone = selectedTimeZone
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
                                }
                                self.presentationMode.wrappedValue.dismiss()
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
            if localSelectedTZ != nil {
                selectedTimeZone = localSelectedTZ
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .navigationBarTitle("select timezone")
        .navigationBarTitleDisplayMode(.inline)
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
        TimeZoneRegionSelector(selectedTimeZone: .constant(TimeZone.current))
    }
}
