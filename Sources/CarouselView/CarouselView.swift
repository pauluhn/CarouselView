//
//  CarouselView.swift
//  CarouselView
//
//  Created by Anbalagan on 24/11/24.
//

import SwiftUI

public struct CarouselView<T, Content: View>: View {
    let items: [T]
    let spacing: CGFloat
    @Binding var selected: T?
    @Binding var selectedIndex: Int
    @ViewBuilder let content: (T) -> Content
    
    @State private var height: CGFloat = 0.0
    @State private var dragOffsetX: CGFloat = 0.0
    @State private var previousOffsetX: CGFloat = 0.0
    @State private var tabItem: [T] = []
    
    public init(
        _ items: [T],
        spacing: CGFloat = 0.0,
        selected: Binding<T?>,
        @ViewBuilder content: @escaping (T) -> Content
    ) {
        self.items = items
        self.spacing = spacing
        self._selectedIndex = Binding.constant(0)
        self._selected = selected
        self.content = content
    }
    
    public init(
        _ items: [T],
        spacing: CGFloat = 0.0,
        selectedIndex: Binding<Int>,
        @ViewBuilder content: @escaping (T) -> Content
    ) {
        self.items = items
        self.spacing = spacing
        self._selectedIndex = selectedIndex
        self._selected = Binding.constant(nil)
        self.content = content
    }
    
    public var body: some View {
        GeometryReader { geometry in
            if !tabItem.isEmpty {
                HStack(spacing: spacing) {
                    content(tabItem[0])
                        .frame(width: geometry.size.width)
                        .onHeightChange { self.height = max(self.height, $0) }
                    content(tabItem[1])
                        .frame(width: geometry.size.width)
                        .onHeightChange { self.height = max(self.height, $0) }
                    content(tabItem[2])
                        .frame(width: geometry.size.width)
                        .onHeightChange { self.height = max(self.height, $0) }
                }
                .offset(x: dragOffsetX)
                .onAppear {
                    dragOffsetX = -(geometry.size.width + spacing)
                }
                .contentShape(.interaction, Rectangle())
                .gesture(
                    DragGesture().onChanged { value in
                        dragOffsetX = dragOffsetX + (value.translation.width - previousOffsetX)
                        previousOffsetX = value.translation.width
                    }.onEnded { value in
                        defer {
                            previousOffsetX = 0
                        }
                        
                        let isReachedThreashold = abs(value.translation.width) > geometry.size.width / 3
                        
                        if !isReachedThreashold {
                            withAnimation(.linear) {
                                dragOffsetX = -(geometry.size.width + spacing)
                            }
                            return
                        }
                        
                        let isForward: Bool
                        if value.startLocation.x > value.location.x {
                            selectedIndex = nextIndex()
                            isForward = true
                        } else {
                            selectedIndex = previousIndex()
                            isForward = false
                        }
                        
                        withAnimation(.linear) {
                            dragOffsetX = isForward ? -geometry.size.width * 2 : 0
                        }
                        
                        dragOffsetX = -(geometry.size.width + spacing)
                        constructTabItem()
                    }
                )
            }
        }
        .frame(height: height)
        .clipped()
//        .background(Color.gray)
        .onAppear { constructTabItem() }
    }
    
    private func constructTabItem() {
        if items.isEmpty {
            tabItem = []
            return
        }
        
        tabItem = [
            items[previousIndex()],
            items[selectedIndex],
            items[nextIndex()]
        ]
    }
    
    private func previousIndex() -> Int {
        (selectedIndex - 1) < 0 ? items.count - 1 : selectedIndex - 1
    }

    private func nextIndex() -> Int {
        (selectedIndex + 1) % items.count
    }
}
