//
//  LoginViewController.swift
//  SwiftMVVM
//
//  Created by jaydeep vadalia on 01/06/22.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    @IBOutlet var loginTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    @IBAction func didTapOnSubmitButton(_ sender: Any) {
        guard let searchText = loginTextField.text, searchText != "" else {
            return
        }
        let vc = SearchListViewController.make(with: ListViewModel(search: searchText))
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
