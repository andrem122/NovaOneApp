//
//  SignUpAddressViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/2/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class SignUpAddressViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Properties
    @IBOutlet weak var addressTableView: UITableView!
    @IBOutlet weak var addressTextField: NovaOneTextField!
    @IBOutlet weak var addAddressButton: NovaOneButton!
    @IBOutlet weak var continueButton: NovaOneButton!
    let defaults = Defaults()
    
    
    var addresses: [String] = []
    
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    func setup() {
        
        // Set first responder
        self.addressTextField.becomeFirstResponder()
        
        // Set delegate and data source for address table view
        self.addressTableView.delegate = self
        self.addressTableView.dataSource = self
        
        //Disable add property button and continue button
        self.continueButton.isEnabled = false
        self.addAddressButton.layer.borderColor = self.defaults.novaOneColorDisabledColor.cgColor
        self.addAddressButton.setTitleColor(self.defaults.novaOneColorDisabledColor, for: .disabled)
        
    }
    
    // Toggles a button between enabled and disabled states based on text field values
    func toggle(button: UIButton, textField: UITextField, enabledColor: UIColor, disabledColor: UIColor, toggleBorderColorOnly: Bool) {
        
        guard
            let text = textField.text
        else { return }
        
        if text.isEmpty {
            
            button.isEnabled = false
            
            if toggleBorderColorOnly == true {
                button.layer.borderColor = disabledColor.cgColor
            } else {
                button.backgroundColor = disabledColor
                button.layer.borderColor = disabledColor.cgColor
            }
            
        } else {
            
            button.isEnabled = true
            
            if toggleBorderColorOnly == true {
                button.layer.borderColor = enabledColor.cgColor
            } else {
                button.backgroundColor = enabledColor
                button.layer.borderColor = enabledColor.cgColor
            }
            
        }
        
    }
    
    // Enable continue button if there is at least one address in the addresses array
    func toggleContinueButton() {
        
        if self.addresses.count > 0 {
            self.continueButton.isEnabled = true
            self.continueButton.backgroundColor = defaults.novaOneColor
        } else {
            self.continueButton.isEnabled = false
            self.continueButton.backgroundColor = defaults.novaOneColorDisabledColor
        }
        
    }
    
    // MARK: Actions
    
    @IBAction func addressEditingChanged(_ sender: Any) {
        
        print("addressEditingChanged function Called")
        self.toggle(button: self.addAddressButton, textField: self.addressTextField, enabledColor: self.defaults.novaOneColor, disabledColor: self.defaults.novaOneColorDisabledColor, toggleBorderColorOnly: true)
        
    }
    
    @IBAction func deleteCellButtonTapped(_ sender: UIButton) {
        
        // Remove item from addresses array and reload table to show the update
        self.addresses.remove(at: sender.tag)
        self.toggleContinueButton()
        self.addressTableView.reloadData()
        
    }
    
    // Add address and clear text field when add button is tapped
    @IBAction func addButtonTapped(_ sender: Any) {
        
        // Get text from text field, add address to address array, and reload table
        guard let address = self.addressTextField.text else { return }
        
        // If text is not an empty string, clear the text field and add the address to the
        // table view/ addresses array
        if !address.isEmpty {
            self.addressTextField.text = ""
            self.addresses.append(address)
            self.toggleContinueButton()
            self.addressTableView.reloadData()
        }
        
    }
    
    
    

}

extension SignUpAddressViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.addresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addressTableViewCell") as! AddAddressTableViewCell
        
        // Get address from address array and add to cell
        let address = self.addresses[indexPath.row]
        cell.setupCell(address: address, cellRow: indexPath.row)
        return cell
    }
    
}
