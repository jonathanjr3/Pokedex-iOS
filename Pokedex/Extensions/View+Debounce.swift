extension View {
    // MARK: - Debounce with Binding
    func debounce<T: Sendable & Equatable>(
        _ query: Binding<T>,
        using channel: AsyncChannel<T>,
        for duration: Duration,
        action: @Sendable @escaping (T) async -> Void
    ) -> some View {
        self
            .task {
                for await query in channel.debounce(for: duration) {
                    await action(query)
                }
            }
            .task(id: query.wrappedValue) {
                await channel.send(query.wrappedValue)
            }
    }

    func debounce<T: Sendable & Equatable>(
        _ query: Binding<T>,
        using channel: AsyncChannel<T>,
        for duration: Duration,
        action: @Sendable @escaping () async -> Void
    ) -> some View {
        self
            .task {
                for await _ in channel.debounce(for: duration) {
                    await action()
                }
            }
            .task(id: query.wrappedValue) {
                await channel.send(query.wrappedValue)
            }
    }

    // MARK: - Debounce with the wrappedValue of a Binding
    func debounce<T: Sendable & Equatable>(
        _ query: T,
        using channel: AsyncChannel<T>,
        for duration: Duration,
        action: @Sendable @escaping (T) async -> Void
    ) -> some View {
        self
            .task {
                for await query in channel.debounce(for: duration) {
                    await action(query)
                }
            }
            .task(id: query) {
                await channel.send(query)
            }
    }

    func debounce<T: Sendable & Equatable>(
        _ query: T,
        using channel: AsyncChannel<T>,
        for duration: Duration,
        action: @Sendable @escaping () async -> Void
    ) -> some View {
        self
            .task {
                for await _ in channel.debounce(for: duration) {
                    await action()
                }
            }
            .task(id: query) {
                await channel.send(query)
            }
    }
}
