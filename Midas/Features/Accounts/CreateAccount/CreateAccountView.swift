//
//  CreateAccountView.swift
//  Midas
//

import SwiftUI

struct CreateAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CreateAccountViewModel

    init(accountRepository: AccountRepositoryProtocol) {
        _viewModel = State(initialValue: CreateAccountViewModel(accountRepository: accountRepository))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                goldAccentLine
                progressSection
                stepContent
                bottomAction
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if viewModel.currentStep != .accountInfo {
                        Button {
                            viewModel.goToPreviousStep()
                        } label: {
                            Image(systemName: "arrow.left")
                                .font(.body)
                                .foregroundStyle(.primary)
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.currentStep == .finalize {
                        Button(role: .confirm) {
                            viewModel.saveAccount()
                        } label: {
                            Label("Establish Account", systemImage: "checkmark")
                        }
                        .disabled(!viewModel.isCurrentStepValid)
                    } else {
                        Button(role: .confirm) {
                            viewModel.goToNextStep()
                        } label: {
                            Image(systemName: "arrow.right")
                                .font(.body)
                                .foregroundStyle(.primary)
                        }
                        .disabled(!viewModel.isCurrentStepValid)
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body)
                            .foregroundStyle(.primary)
                    }
                }
            }
            .onChange(of: viewModel.didSave) { _, didSave in
                if didSave { dismiss() }
            }
        }
    }
}

// MARK: - Gold Accent Line

private extension CreateAccountView {
    var goldAccentLine: some View {
        Rectangle()
            .fill(Color(red: 0.76, green: 0.63, blue: 0.35))
            .frame(height: 2)
    }
}

// MARK: - Progress Section

private extension CreateAccountView {
    var progressSection: some View {
        StepProgressBar(
            currentStep: viewModel.currentStep.rawValue,
            totalSteps: CreateAccountStep.allCases.count,
            percentComplete: viewModel.currentStep.progressPercentage
        )
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
}

// MARK: - Step Content

private extension CreateAccountView {
    @ViewBuilder
    var stepContent: some View {
        switch viewModel.currentStep {
        case .accountInfo:
            AccountInfoStepView(viewModel: viewModel)
        case .accountSpecifics:
            AccountSpecificsStepView(viewModel: viewModel)
        case .finalize:
            FinalizeAccountStepView(viewModel: viewModel)
        }
    }
}

// MARK: - Bottom Action

private extension CreateAccountView {
    @ViewBuilder
    var bottomAction: some View {
        VStack(spacing: 12) {
            switch viewModel.currentStep {
            case .accountInfo:
                EmptyView()
            case .accountSpecifics:
                saveForLaterButton
            case .finalize:
                legalDisclaimer
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }

    var saveForLaterButton: some View {
        Button {
            dismiss()
        } label: {
            Text("Save for Later")
                .font(.subheadline)
                .foregroundStyle(.primary)
                .underline()
        }
    }

    var legalDisclaimer: some View {
        Text("By clicking establish, you agree to our Terms of Service and Portfolio Mandates.")
            .font(.caption2)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
    }
}

#Preview {
    CreateAccountView(accountRepository: InMemoryAccountRepository())
}
