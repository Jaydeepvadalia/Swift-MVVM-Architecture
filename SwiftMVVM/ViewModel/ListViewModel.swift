//
//  SearchViewModel.swift
//  SwiftMVVM
//
//  Created by jaydeep vadalia on 01/06/22.
//

import Foundation
import Moya
import RxSwift
import RxCocoa
import Action

protocol ListViewModelInputs {
    var fetchTrigger: PublishSubject<Void> { get }
    var reachedBottomTrigger: PublishSubject<Void> { get }
}

protocol ListViewModelOutputs {
    var navigationBarTitle: Observable<String> { get }
    var users: Observable<[User]> { get }
    var isLoading: Observable<Bool> { get }
    var error: Observable<NSError> { get }
}

protocol ListViewModelType {
    var inputs: ListViewModelInputs { get }
    var outputs: ListViewModelOutputs { get }
}

final class ListViewModel: ListViewModelType, ListViewModelInputs, ListViewModelOutputs {

    var inputs: ListViewModelInputs { return self }
    var outputs: ListViewModelOutputs { return self }

    // MARK: - Inputs
    let fetchTrigger = PublishSubject<Void>()
    let reachedBottomTrigger = PublishSubject<Void>()
    let search = ""
    private let page = BehaviorRelay<Int>(value: 1)

    // MARK: - Outputs
    let navigationBarTitle: Observable<String>
    let users: Observable<[User]>
    let isLoading: Observable<Bool>
    let error: Observable<NSError>
    
   

    let searchAction: Action<Int,[User]>
    private let disposeBag = DisposeBag()
    let errorDataSourcePublisher: PublishSubject<Error> = PublishSubject()
    let provider: MoyaProvider<SwiftMVVMAPI>
    init(search: String, provider: MoyaProvider<SwiftMVVMAPI> = MoyaProvider(plugins: [NetworkLoggerPlugin()])) {
        self.provider = provider
        
        self.navigationBarTitle = Observable.just(search)
        
        
        let response = BehaviorRelay<[User]>(value: [])
        self.users = response.asObservable()

        self.searchAction = Action { page in
            return provider.rx
                .request(SwiftMVVMAPI.searchUser(search, page, 9))
                .asObservable()
                .debug(#function, trimOutput: true)
                .filterSuccessfulStatusAndRedirectCodes()
                .retry(2)
                .flatMap { response -> Single<[User]> in
                        do {
                            let users = try response.map([User].self, atKeyPath: "items")
                            return Single.just(users)
                        } catch let error {
                            return Single.error(error)
                        }
                     }
        }
        
        self.isLoading = searchAction.executing.startWith(false)
        self.error = searchAction.errors.map { _ in NSError(domain: "Network Error", code: 0, userInfo: nil) }
        
        searchAction.elements
            .withLatestFrom(response) { ($0, $1) }
            .map { $0.1 + $0.0 }
            .bind(to: response)
            .disposed(by: disposeBag)

        searchAction.elements
            .withLatestFrom(page)
            .map { $0 + 1 }
            .bind(to: page)
            .disposed(by: disposeBag)

        fetchTrigger
            .withLatestFrom(page)
            .bind(to: searchAction.inputs)
            .disposed(by: disposeBag)

        reachedBottomTrigger
            .withLatestFrom(isLoading)
            .filter { !$0 }
            .withLatestFrom(page)
            .filter { $0 < 500 }
            .bind(to: searchAction.inputs)
            .disposed(by: disposeBag)
    }
    
   
    
    class func searchUser(search: String, page: Int, perPage: Int) -> Observable<[User]> {
        let provider: MoyaProvider<SwiftMVVMAPI> = MoyaProvider(plugins: [NetworkLoggerPlugin()])
        return provider.rx
            .request(SwiftMVVMAPI.searchUser(search, page, 9))
            .asObservable()
            .filterSuccessfulStatusAndRedirectCodes()
            
            .flatMap { response -> Single<[User]> in
                    do {
                        let users = try response.map([User].self, atKeyPath: "items")
                        return Single.just(users)
                    } catch let error {
                        return Single.error(error)
                    }
                 }
    }
}
