import Foundation

final class MatchDetailViewModel {

    var onLoaded: ((MatchDetailData) -> Void)?
    var onFailed: ((String) -> Void)?

    private let matchID: Int
    private let service: MatchDetailProviding
    private let activityStore: ActivityStoring

    init(matchID: Int,
         service: MatchDetailProviding,
         activityStore: ActivityStoring = UserDefaultsActivityStore.shared) {
        self.matchID = matchID
        self.service = service
        self.activityStore = activityStore
    }

    func load() {
        service.fetchMatchDetail(id: matchID) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                // Profildəki Activity siyahısı üçün son baxılan oyun kimi yadda saxlanır.
                self.activityStore.record(
                    matchID: self.matchID,
                    title: "\(data.homeName) vs \(data.awayName)",
                    subtitle: data.competitionName
                )
                self.onLoaded?(data)
            case .failure(let error):
                self.onFailed?(error.localizedDescription)
            }
        }
    }
}

