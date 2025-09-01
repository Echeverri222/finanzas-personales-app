//
//  SupabaseManager.swift
//  finanzas-personales-app
//
//  Supabase configuration and client setup
//

import Foundation
import Supabase

final class FinanzasSupabaseManager {
    static let shared = FinanzasSupabaseManager()
    
    private let supabaseURL = "https://vvzadoagclwzjuhgbwgf.supabase.co"
    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ2emFkb2FnY2x3emp1aGdid2dmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg2NDY5NTIsImV4cCI6MjA2NDIyMjk1Mn0.NrSY7d1GkwkAFOG5ul7-_MJGrHf1kCA_UFjfPEWuw7U"
    
    lazy var client: SupabaseClient = {
        return SupabaseClient(
            supabaseURL: URL(string: supabaseURL)!,
            supabaseKey: supabaseKey
        )
    }()
    
    private init() {}
}

// MARK: - Environment Configuration
extension FinanzasSupabaseManager {
    /// Configure with your actual Supabase credentials
    /// You should replace the placeholder values above with your actual:
    /// - Project URL (found in your Supabase dashboard under Settings > API)
    /// - Anon/Public key (also in Settings > API)
    ///
    /// For security, consider using a plist file or environment variables
    /// instead of hardcoding the values here.
}
