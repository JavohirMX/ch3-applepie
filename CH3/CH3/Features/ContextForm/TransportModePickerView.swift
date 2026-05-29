import SwiftUI

struct TransportModePickerView: View {
    @Binding var path: [AppRoute]

    private let theme = CategoryTheme.theme(for: .transport)
    private let modes: [ContextFormType] = [.airport, .bus, .cab]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose how you're traveling")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)

            ForEach(modes, id: \.self) { mode in
                Button {
                    path.append(.contextForm(mode))
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: mode.iconSystemName)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(theme.primary)
                            .clipShape(Circle())
                        Text(mode.title)
                            .font(AppTypography.listTitle)
                            .foregroundStyle(AppColors.textPrimary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .padding(14)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Transport")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}
