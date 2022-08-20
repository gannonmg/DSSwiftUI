//
//  HomeView.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 8/14/22.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var errorHandling: ErrorHandling
    @StateObject var viewModel: ReleaseListViewModel = .init()
    
    var body: some View {
        VStack(spacing: 0) {
            ReleaseListHeaderView()
            conditionalView
                .layoutPriority(1)
        }
        .environmentObject(viewModel)
        .overlay(alignment: .bottom) {
            LinearGradient(
                colors: [.clear, .black.opacity(0.8)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
            .height(60)
            .allowsHitTesting(false)
        }
        .overlay(
            alignment: .bottomTrailing,
            content: { shuffleButton }
        )
        .sheet(isPresented: $viewModel.showingFilters) {
            FilterView()
                .environmentObject(viewModel.filterController)
        }
        .sheet(isPresented: $appViewModel.showingLastFmLogin) {
            LFLoginView()
        }
        .sheet(item: $viewModel.selectedRelease) { release in
            ReleaseDetailView(release: release)
        }
    }
    
    var conditionalView: some View {
        if viewModel.trulyEmpty {
            return AnyView(getReleasesView)
        } else if viewModel.releases.isEmpty {
            return AnyView(noSearchResultsView)
        } else {
            return AnyView(
                ReleaseListView()
            )
        }
    }
    
    var getReleasesView: some View {
        VStack {
            Text("There doesn't seem to be anything here...")
                .appFont(.robotoMedium, size: 16)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            
            VSSecondaryButton("Get Releases", action: viewModel.getRemoteReleases)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Color.vsBackground
        }
        .ignoresSafeArea()
    }
        
    var noSearchResultsView: some View {
        VStack {
            Text("No albums match your search criteria")
                .appFont(.robotoMedium, size: 16)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            
            VSSecondaryButton(
                "Clear Search",
                action: viewModel.clearSearchAndFilter
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Color.vsBackground
        }
        .ignoresSafeArea()
    }
    
    var shuffleButton: some View {
        Button(action: viewModel.pickRandomRelease) {
            ZStack {
                Circle().frame(width: 48, height: 48).foregroundColor(.white)
                Image.shuffleIcon.foregroundColor(.vsDarkText)
            }
        }
        .shadow(
            color: .vsShadowColor,
            radius: 4,
            x: 0, y: 4
        )
        .padding(.trailing, 12)
        .padding(.bottom, 16)
    }
}
