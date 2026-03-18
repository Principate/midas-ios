//
//  HomeViewModelTests.swift
//  MidasTests
//

import Testing
@testable import Midas

@MainActor
struct HomeViewModelTests {

    @Test func test_init_shouldSetDefaultGreeting() {
        let viewModel = HomeViewModel()
        #expect(viewModel.greeting == "Hello, world!")
    }
}
