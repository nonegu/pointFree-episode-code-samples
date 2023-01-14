
import SwiftUI

struct ContentView: View {
  @ObservedObject var state: AppState

  var body: some View {
    NavigationView {
      List {
        NavigationLink(destination: CounterView(state: self.state)) {
          Text("Counter demo")
        }
        NavigationLink(destination: EmptyView()) {
          Text("Favorite primes")
        }
      }
      .navigationBarTitle("State management")
    }
  }
}

private func ordinal(_ n: Int) -> String {
  let formatter = NumberFormatter()
  formatter.numberStyle = .ordinal
  return formatter.string(for: n) ?? ""
}

//BindableObject

import Combine

class AppState: Codable, ObservableObject {
    @Published var count = 0 {
        didSet {
            guard let jsonData = try? JSONEncoder().encode(self) else { return }
            UserDefaults.standard.set(jsonData, forKey: AppState.source)
        }
    }
    static var source = "AppState"
    
    enum CodingKeys: String, CodingKey {
        case count
    }
    
    init() {}
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        count = try values.decode(Int.self, forKey: .count)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(count, forKey: .count)
    }
}

struct CounterView: View {
  @ObservedObject var state: AppState

  var body: some View {
    VStack {
      HStack {
        Button(action: { self.state.count -= 1 }) {
          Text("-")
        }
        Text("\(self.state.count)")
        Button(action: { self.state.count += 1 }) {
          Text("+")
        }
      }
      Button(action: {}) {
        Text("Is this prime?")
      }
      Button(action: {}) {
        Text("What is the \(ordinal(self.state.count)) prime?")
      }
    }
    .font(.title)
    .navigationBarTitle("Counter demo")
  }
}


import PlaygroundSupport

let appState: AppState
if let appStateData = UserDefaults.standard.data(forKey: AppState.source),
    let savedState = try? JSONDecoder().decode(AppState.self, from: appStateData) {
    appState = savedState
} else {
    appState = AppState()
}

let rootView = ContentView(state: appState)
    .frame(width: 375, height: 667)
PlaygroundPage.current.setLiveView(rootView)
