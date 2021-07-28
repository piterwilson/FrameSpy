 ## FrameSpy
 
A family of objects that can be used to "spy" on a `View` and collect its `frame` (a `CGRect` describing position and size) relative to a coordinate space.
 
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
