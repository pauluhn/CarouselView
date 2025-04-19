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

    private var isFirst: Bool { selectedIndex == 0 }
    private var isLast: Bool { selectedIndex == items.count - 1 }

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
                    firstView
                        .frame(width: geometry.size.width)
                        .onHeightChanged { self.height = max(self.height, $0) }
                    content(tabItem[1])
                        .frame(width: geometry.size.width)
                        .onHeightChanged { self.height = max(self.height, $0) }
                    lastView
                        .frame(width: geometry.size.width)
                        .onHeightChanged { self.height = max(self.height, $0) }
                }
                .offset(x: dragOffsetX)
                .onAppear {
                    dragOffsetX = -(geometry.size.width + spacing)
                }
                .contentShape(.interaction, Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0).onChanged { value in
                        dragOffsetX = dragOffsetX + (value.translation.width - previousOffsetX)
                        previousOffsetX = value.translation.width
                    }.onEnded { value in
                        defer {
                            previousOffsetX = 0
                        }
                        let resetClosure = {
                            withAnimation {
                                dragOffsetX = -(geometry.size.width + spacing)
                            }
                        }

                        let isReachedThreshold = abs(value.translation.width) > geometry.size.width / 3
                        
                        if !isReachedThreshold {
                            resetClosure()
                            return
                        }
                        
                        let isForward: Bool
                        if value.startLocation.x > value.location.x {
                            guard !isLast else { resetClosure(); return }
                            selectedIndex = nextIndex()
                            isForward = true
                        } else {
                            guard !isFirst else { resetClosure(); return }
                            selectedIndex = previousIndex()
                            isForward = false
                        }
                        
                        withAnimation {
                            dragOffsetX = isForward ? -geometry.size.width * 2 : 0
                        }
                        
                        dragOffsetX = -(geometry.size.width + spacing)
                    }
                )
                .onChange(of: selectedIndex) { _ in
                    constructTabItem()
                }
            }
        }
        .frame(height: height)
        .clipped()
        .onAppear { constructTabItem() }
    }

    @ViewBuilder
    private var firstView: some View {
        if !isFirst {
            content(tabItem[0])
        } else {
            Color.clear
        }
    }

    @ViewBuilder
    private var lastView: some View {
        if !isLast {
            content(tabItem[2])
        } else {
            Color.clear
        }
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
