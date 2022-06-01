//
//  SearchListViewController.swift
//  SwiftMVVM
//
//  Created by jaydeep vadalia on 01/06/22.
//

import UIKit
import RxCocoa
import RxSwift

class SearchListViewController: UIViewController {

    static func make(with viewModel: ListViewModel) -> SearchListViewController {
        let view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchListViewController") as! SearchListViewController
        view.viewModel = viewModel
        return view
    }
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var indicatorView: UIActivityIndicatorView!

    private var viewModel: ListViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Bind ViewModel Outputs
        viewModel.outputs.navigationBarTitle
            .observe(on: MainScheduler.instance)
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)

        viewModel.outputs.users
            .asDriver(onErrorJustReturn: [])
                .drive(tableView.rx.items(cellIdentifier: "UserTableViewCell",
                                                    cellType: UserTableViewCell.self)) { _, element, cell in
                    cell.configCell(user: element)
                }
            .disposed(by: disposeBag)

        

        viewModel.outputs.isLoading
            .observe(on: MainScheduler.instance)
            .bind(to: indicatorView.rx.isAnimating)
            .disposed(by: disposeBag)

        viewModel.outputs.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: $0 ? 50 : 0, right: 0)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                let ac = UIAlertController(title: "Error \($0)", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(ac, animated: true)
            })
            .disposed(by: disposeBag)
        

        // Bind ViewModel Inputs
        tableView.rx.reachedBottom.asObservable()
            .bind(to: viewModel.inputs.reachedBottomTrigger)
            .disposed(by: disposeBag)

        viewModel.inputs.fetchTrigger.onNext(())
    }

}
