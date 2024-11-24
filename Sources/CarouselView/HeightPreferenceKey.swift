//
//  HeightPreferenceKey.swift
//  CarouselView
//
//  Created by Anbalagan on 24/11/24.
//

import SwiftUI

struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat { .zero }
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
