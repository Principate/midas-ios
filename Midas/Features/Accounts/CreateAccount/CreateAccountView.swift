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
        VStack(spacing: 0) {
            topBar
            progressSection
            stepContent
            bottomAction
        }
        .background(Color(.systemBackground))
        .onChange(of: viewModel.didSave) { _, didSave in
            if didSave { dismiss() }
        }
    }
}

// MARK: - Top Bar

private extension CreateAccountView {
    var topBar: some View {
        VStack(spacing: 0) {
            HStack {
                if viewModel.currentStep != .accountInfo {
                    Button {
                        viewModel.goToPreviousStep()
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(.body)
                            .foregroundStyle(.primary)
                    }
                }

                Spacer()

                Text("EDITORIAL WEALTH")
                    .font(.caption)
                    .tracking(3)
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.body)
                        .foregroundStyle(.primary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            // Gold accent line
            Rectangle()
                .fill(Color(red: 0.76, green: 0.63, blue: 0.35))
                .frame(height: 2)
        }
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
            case .accountInfo, .accountSpecifics:
                continueButton
                if viewModel.currentStep == .accountSpecifics {
                    saveForLaterButton
                }
            case .finalize:
                establishButton
                legalDisclaimer
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }

    var continueButton: some View {
        Button {
            viewModel.goToNextStep()
        } label: {
            Text("CONTINUE")
                .font(.subheadline)
                .fontWeight(.semibold)
                .tracking(2)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.brandDarkGreen)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .disabled(!viewModel.isCurrentStepValid)
        .opacity(viewModel.isCurrentStepValid ? 1 : 0.5)
    }

    var establishButton: some View {
        Button {
            viewModel.saveAccount()
        } label: {
            HStack(spacing: 8) {
                Text("ESTABLISH ACCOUNT")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .tracking(2)
                Image(systemName: "arrow.right")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.brandDarkGreen)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .disabled(!viewModel.isCurrentStepValid)
        .opacity(viewModel.isCurrentStepValid ? 1 : 0.5)
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
