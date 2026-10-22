//
//  CrashReporter.swift
//  FootballApp
//
//  Crashlytics bir protokolun arxasındadır: tətbiq kodu Firebase-ə birbaşa bağlı deyil,
//  testlərdə isə saxta versiya ötürmək mümkündür.
//

import Foundation
import FirebaseCrashlytics

protocol CrashReporting {
    /// Crash hesabatlarında istifadəçini ayırd etmək üçün (Firebase UID; email yox).
    func setUser(id: String?)
    /// Crash olmayan, amma araşdırılmalı xəta (məsələn, API cavabı oxunmadı).
    func record(_ error: Error, context: String)
    /// Crash-dən əvvəlki addımları görmək üçün qısa qeyd ("breadcrumb").
    func log(_ message: String)
}

struct FirebaseCrashReporter: CrashReporting {

    static let shared = FirebaseCrashReporter()

    func setUser(id: String?) {
        Crashlytics.crashlytics().setUserID(id ?? "")
    }

    func record(_ error: Error, context: String) {
        Crashlytics.crashlytics().record(error: error, userInfo: ["context": context])
    }

    func log(_ message: String) {
        Crashlytics.crashlytics().log(message)
    }
}

enum CrashReportingSetup {

    /// `FirebaseApp.configure()`-dan sonra çağırılır.
    ///
    /// - Release: həmişə açıqdır.
    /// - Debug: söndürülüb ki, sınaq zamanı crash-lər statistikanı qarışdırmasın.
    ///   Yoxlamaq üçün scheme-ə `-crashlytics` launch argumentini əlavə et.
    /// - `-forceCrash` (yalnız Debug): tətbiq 3 saniyə sonra qəsdən crash edir.
    static func configure(arguments: [String] = ProcessInfo.processInfo.arguments) {
        #if DEBUG
        let isEnabled = arguments.contains("-crashlytics")
        #else
        let isEnabled = true
        #endif
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(isEnabled)

        #if DEBUG
        if arguments.contains("-forceCrash") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                fatalError("Crashlytics test crash (-forceCrash)")
            }
        }
        #endif
    }
}
