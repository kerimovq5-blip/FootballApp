//
//  HomeViewModelTests.swift
//  FootballAppTests
//

import Foundation
import Testing
@testable import FootballApp

@Suite("HomeViewModel")
@MainActor
struct HomeViewModelTests {

    private let service: FakeHomeService
    private let viewModel: HomeViewModel

    /// Hər test öz təmiz servis və ViewModel-i ilə başlayır.
    init() {
        let service = FakeHomeService()
        self.service = service
        viewModel = HomeViewModel(service: service)
    }

    /// Bölmələri müqayisə üçün mətnə çevirir (HomeSection Equatable deyil).
    private var sectionNames: [String] {
        viewModel.sections.map { section in
            switch section {
            case .banner: return "banner"
            case .day: return "day"
            case .filter: return "filter"
            case .league(let index): return "league\(index)"
            case .empty: return "empty"
            }
        }
    }

    /// Bir bitmiş, bir canlı oyun.
    private var premierLeague: League {
        TestData.league(id: 39, matches: [
            TestData.match(id: 1, status: .finished),
            TestData.match(id: 2, status: .live(minute: "67'"))
        ])
    }

    /// Yalnız başlamamış oyun.
    private var laLiga: League {
        TestData.league(id: 140, name: "La Liga", matches: [
            TestData.match(id: 3, status: .scheduled(kickoff: "21:00"))
        ])
    }

    // MARK: - Yükləmə

    @Test("İlk yükləmə bu günü (offset 0) soruşur")
    func loadRequestsToday() {
        viewModel.load()
        #expect(service.requestedOffsets == [0])
    }

    @Test("Cavab gələndə liqalar bölmə kimi əlavə olunur və ekran xəbərdar edilir")
    func loadSuccess() {
        var changes = 0
        viewModel.onChange = { changes += 1 }

        viewModel.load()
        service.respond(0, leagues: [premierLeague, laLiga])

        #expect(sectionNames == ["banner", "day", "filter", "league0", "league1"])
        #expect(viewModel.filteredLeagues.map(\.id) == [39, 140])
        #expect(changes == 1)
    }

    @Test("Cavab gəlməmiş \"oyun yoxdur\" bölməsi göstərilmir")
    func noEmptyStateWhileLoading() {
        viewModel.load()
        #expect(sectionNames == ["banner", "day", "filter"])
    }

    @Test("Oyun olmayan gündə \"oyun yoxdur\" bölməsi göstərilir")
    func emptyDay() {
        viewModel.load()
        service.respond(0, leagues: [])

        #expect(sectionNames == ["banner", "day", "filter", "empty"])
        #expect(viewModel.emptyMessage == "No matches on this day.")
    }

    @Test("Xəta olanda mesaj ekrana ötürülür")
    func loadFailure() {
        var failure: String?
        viewModel.onFailed = { failure = $0 }

        viewModel.load()
        service.fail(0, message: "No internet")

        #expect(failure == "No internet")
        #expect(sectionNames == ["banner", "day", "filter"])
    }

    // MARK: - Filtr

    @Test("Live filtri yalnız canlı oyunları və onları olan liqaları saxlayır")
    func liveFilter() {
        viewModel.load()
        service.respond(0, leagues: [premierLeague, laLiga])

        viewModel.selectFilter(.live)

        #expect(viewModel.filteredLeagues.map(\.id) == [39])
        #expect(viewModel.filteredLeagues.first?.matches.map(\.id) == [2])
        #expect(sectionNames == ["banner", "day", "filter", "league0"])
    }

    @Test("Canlı oyun yoxdursa Live filtrinin öz mesajı göstərilir")
    func liveFilterEmpty() {
        viewModel.load()
        service.respond(0, leagues: [laLiga])

        viewModel.selectFilter(.live)

        #expect(sectionNames.last == "empty")
        #expect(viewModel.emptyMessage == "No live matches right now.")
    }

    @Test("Eyni filtri yenidən seçmək ekranı yeniləmir")
    func sameFilterIgnored() {
        var changes = 0
        viewModel.onChange = { changes += 1 }

        viewModel.selectFilter(.all)
        #expect(changes == 0)
    }

    // MARK: - Gün seçimi

    @Test("Gün dəyişəndə yeni sorğu gedir və köhnə günün oyunları dərhal silinir")
    func selectDay() {
        viewModel.load()
        service.respond(0, leagues: [premierLeague])

        viewModel.selectDay(.tomorrow)

        #expect(service.requestedOffsets == [0, 1])
        #expect(viewModel.selectedDay == .tomorrow)
        #expect(viewModel.filteredLeagues.isEmpty)
        #expect(sectionNames == ["banner", "day", "filter"])   // yüklənir, hələ "boş" deyil
    }

    @Test("Eyni günü yenidən seçmək yeni sorğu göndərmir")
    func sameDayIgnored() {
        viewModel.load()
        viewModel.selectDay(.today)
        #expect(service.requestedOffsets == [0])
    }

    @Test("Gec gələn köhnə cavab yeni seçilmiş günün üstünə yazılmır")
    func staleResponseIgnored() {
        viewModel.load()                    // sorğu 0: bu gün
        viewModel.selectDay(.tomorrow)      // sorğu 1: sabah

        service.respond(1, leagues: [laLiga])            // sabahın cavabı əvvəl gəlir
        service.respond(0, leagues: [premierLeague])     // bu günün köhnə cavabı gec gəlir

        #expect(viewModel.filteredLeagues.map(\.id) == [140])
    }

    // MARK: - Axtarış (lookup)

    @Test("Bölmə və sıra nömrəsinə görə düzgün oyun qaytarılır")
    func matchLookup() {
        viewModel.load()
        service.respond(0, leagues: [premierLeague, laLiga])

        #expect(viewModel.match(at: IndexPath(item: 1, section: 3))?.id == 2)
        #expect(viewModel.match(at: IndexPath(item: 0, section: 4))?.id == 3)
        #expect(viewModel.league(inSection: 0) == nil)    // banner bölməsi liqa deyil
    }
}
