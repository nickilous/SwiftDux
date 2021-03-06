import Combine
import SwiftUI

/// A view modifier that injects a store into the environment.
public struct StoreProviderViewModifier<State>: ViewModifier where State: StateType {
  private var store: Store<State>
  private var connection: StateConnection<State>

  @usableFromInline internal init(store: Store<State>) {
    self.store = store
    self.connection = StateConnection<State>(
      getState: { [weak store] in
        guard let store = store else { return nil }
        return store.state
      },
      changePublisher: store.didChange,
      emitChanges: false
    )
  }

  public func body(content: Content) -> some View {
    content
      .environmentObject(connection)
      .environment(\.actionDispatcher, store)
      .environment(\.storeUpdated, store.didChange)
  }
}

extension View {

  /// Injects a store into the environment.
  ///
  /// The store can then be used by the `@EnvironmentObject`
  /// property wrapper. This method also enables the use of `View.mapState(updateOn:_:)` to
  /// map substates to a view.
  /// ```
  /// struct RootView: View {
  ///   // Passed in from the AppDelegate or SceneDelegate class.
  ///   var store: Store<AppState>
  ///
  ///
  ///   var body: some View {
  ///     RootAppNavigation()
  ///       .provideStore(store)
  ///   }
  ///
  /// }
  /// ```
  /// - Parameter store: The store object to inject.
  /// - Returns: The modified view.
  @inlinable public func provideStore<State>(_ store: Store<State>) -> some View where State: StateType {
    return modifier(StoreProviderViewModifier<State>(store: store))
  }
}
