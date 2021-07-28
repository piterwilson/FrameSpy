//
//  FrameSpy.swift
//
//  Created by Juan Carlos Ospina Gonzalez on 28/07/2021.
//

// System
import Foundation
import SwiftUI

/**
 ## FrameSpy
 
 This family of objects can be used to "spy" on a `View` and collect its `frame` (a `CGRect` describing position and size) relative to a coordinate space.
 
 ## How to use
 
 ### 1. Give a name to your coordinate space using the `.coordinateSpace(name:)` `ViewModifier`.
 ```swift
 import FrameSpy
 
 struct ContentView: View {
     var body: some View {
         VStack(spacing: 10.0) {
             Text("Text 1")
         }
         .coordinateSpace(name: "ContentView") // the coordinate space is now named "ContentView".
     }
 }
 ```
 
 ### 2. Declare a "bag" to collect spied frames.
 
 ```swift
 import FrameSpy
 
 struct ContentView: View {
     @State var spiedFrames: SpiedFramesBag = SpiedFramesBag() // spied frames will be collected here.
     var body: some View {
         VStack(spacing: 10.0) {
             Text("Text 1")
         }
         .coordinateSpace(name: "ContentView")
     }
 }
 ```
 
 ### 3. Spy the `View`s frame(s) using `.spyFrame(named:inCoordinateSpaceNamed:)`.
 
 ```swift
 import FrameSpy
 
 struct ContentView: View {
     @State var spiedFrames: SpiedFramesBag = SpiedFramesBag()
     var body: some View {
         VStack(spacing: 10.0) {
             Text("Text 1")
                .spyFrame(named: "text-1", inCoordinateSpaceNamed: "ContentView")  // This `Text`s frame is now "spied" in the coordinate space "ContentView". The spied frame's name is "text-1"
         }
         .coordinateSpace(name: "ContentView")
     }
 }
 ```
 
 ### 4. Collect the spied frame(s) in the bag declared in step 1 using the `.collectSpiedFrames(into:)` `ViewModifier`.
 
 ```swift
 import FrameSpy
 
 struct ContentView: View {
     @State var spiedFrames: SpiedFramesBag = SpiedFramesBag()
     var body: some View {
         VStack(spacing: 10.0) {
             Text("Text 1")
                 .spyFrame(named: "text-1", inCoordinateSpaceNamed: "ContentView")
         }
         .coordinateSpace(name: "ContentView")
         .collectSpiedFrames(into: $spiedFrames) // The spied frames will be collected into `$spiedFrames`
     }
 }
 ```
 The frame for the `Text` will be available as `spiedFrames["text-1"]`. Remember this value is `Optional` and might not be always available.
 */

/// A data structure to collect "spied" frames. It's just a `typealias` for `[String: CGRect]`.
public typealias SpiedFramesBag = [String: CGRect]

public struct FrameSpyPreferenceData: Equatable {
    let identifier: String
    let rect: CGRect
}

public struct FrameSpyPreferenceKey: PreferenceKey {
    public typealias Value = [FrameSpyPreferenceData]
    public static var defaultValue: [FrameSpyPreferenceData] = []
    public static func reduce(value: inout [FrameSpyPreferenceData], nextValue: () -> [FrameSpyPreferenceData]) {
        value.append(contentsOf: nextValue())
    }
}

public struct FrameSpyPreferenceView: View {
    public let identifier: String
    public let coordindateSpaceName: String
    public var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(Color.clear)
                .preference(key: FrameSpyPreferenceKey.self,
                            value: [FrameSpyPreferenceData(identifier: identifier, rect: geometry.frame(in: .named(coordindateSpaceName)))])
        }
    }
}

public struct SpiedFramesCollector: ViewModifier {
    @Binding private var bag: SpiedFramesBag
    public init(bag: Binding<SpiedFramesBag>) {
        self._bag = bag
    }
    public func body(content: Content) -> some View {
        content
            .onPreferenceChange(FrameSpyPreferenceKey.self) { preference in
                preference.forEach { p in
                    bag[p.identifier] = p.rect
                }
            }
    }
}

public struct SpiedFrameCollector: ViewModifier {
    public var identifier: String
    public var coordindateSpaceName: String
    public func body(content: Content) -> some View {
        content
            .background(FrameSpyPreferenceView(identifier: identifier, coordindateSpaceName: coordindateSpaceName))
    }
}

public extension View {
    /**
    "Spies" the value of the `View`'s frame (a `CGRect` describing position and size) relative to a coordinate space named using `.coordinateSpace(name:)`.
     
     Sample usage:
     ```
     struct ContentView: View {
         @State var spiedFrames: SpiedFramesBag = SpiedFramesBag()
         var body: some View {
             VStack(spacing: 10.0) {
                 Text("Text 1")
                     .spyFrame(named: "text-1", inCoordinateSpaceNamed: "ContentView")
                 if let frame = spiedFrames["text-1"] {
                     Text("Text 1 position: (x: **\(frame.minX)** y: **\(frame.minY)** **\(frame.size.width)x\(frame.size.height)**)")
                 }
             }
             .coordinateSpace(name: "ContentView")
             .collectSpiedFrames(into: $spiedFrames)
         }
     }
     ```
     
     - Parameters:
        - name: Unique name to identify the frame of this `View` in the spied frames bag.
        - coordinateSpaceName: The name of the coordinate space relative to wich the frame of this `View` will be collected.
     */
    func spyFrame(named name: String, inCoordinateSpaceNamed coordinateSpaceName: String) -> some View {
        self.modifier(SpiedFrameCollector(identifier: name, coordindateSpaceName:  coordinateSpaceName))
    }
    /**
    "collects" `View` frames "spied" using the `.spyFrame(named:inCoordinateSpaceNamed:)` modifier into a .`SpiedFramesBag`.
     - Parameters:
        - bag: A data structure to collect "spied" frames.
     */
    func collectSpiedFrames(into bag: Binding<SpiedFramesBag>) -> some View {
        self.modifier(SpiedFramesCollector(bag: bag))
    }
}
