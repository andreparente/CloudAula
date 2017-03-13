//
//  TelephoneVC.swift
//  CloudAula
//
//  Created by Andre Machado Parente on 07/03/17.
//  Copyright © 2017 Andre Machado Parente. All rights reserved.
//

import UIKit
import CloudKit

class TelephoneVC: UIViewController {
    
    var contact: Contact!
    //indice
    var activityIndicator = UIActivityIndicatorView()
    @IBOutlet weak var telephonesTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = contact.name
        telephonesTableView.delegate = self
        telephonesTableView.dataSource = self
        //Activity Indicator
        
        //        if contact.telephones.count == 0 {
        //            //Cloud
        //            activityIndicator.startAnimating()
        //            activityIndicator.activityIndicatorViewStyle = .whiteLarge
        //            activityIndicator.color = UIColor.black
        //            activityIndicator.hidesWhenStopped = true
        //            activityIndicator.center = view.center
        //            view.addSubview(activityIndicator)
        //
        //            DAO().fetchTelephonesFromContact(contact: contact)
        //        } else {
        //        }
        //
        //        NotificationCenter.default.addObserver(self, selector: #selector(TelephoneVC.actOnNotificationSuccessFetchTelephones), name: NSNotification.Name(rawValue: "notificationSuccessFetchTelephones"), object: nil)
        //        NotificationCenter.default.addObserver(self, selector: #selector(TelephoneVC.actOnNotificationSuccessCadastroTelephone), name: NSNotification.Name(rawValue: "notificationSuccessCadastroTelephone"), object: nil)
        //        // Do any additional setup after loading the view.
        //        //adicionar a cloud
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //    func actOnNotificationSuccessCadastroTelephone() {
    //        DispatchQueue.main.async {
    //            self.telephonesTableView.reloadData()
    //
    //        }
    //    }
    //
    //    func actOnNotificationSuccessFetchTelephones() {
    //        DispatchQueue.main.async {
    //            self.telephonesTableView.reloadData()
    //            self.activityIndicator.stopAnimating()
    //        }
    //    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func addTelephone(_ sender: UIBarButtonItem) {
        //adicionar telefone
        let alertController = UIAlertController(title: "Add New Telephone", message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            
            let telephoneTextField = alertController.textFields![1] as UITextField
            let typeTextField = alertController.textFields![0] as UITextField
            
            if telephoneTextField.text != "" && typeTextField.text != "" {
                if telephoneTextField.text != nil && typeTextField.text != nil {
                    print("telephone \(telephoneTextField.text), type \(typeTextField.text)")
                    let telephone = Telephone(type: typeTextField.text!, number: Int(telephoneTextField.text!)!)
                    //salvar no cloud e notification pra recarregar tableView
                    //   DAO().addTelephone(telephone: telephone, contact: self.contact)
                }
            }
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter type"
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.keyboardType = .numberPad
            textField.placeholder = "Enter telephone"
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension TelephoneVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if contact.telephones.count != 0 {
            return contact.telephones.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = telephonesTableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        print(contact.telephones)
        if contact.telephones.count != 0 {
            cell.detailTextLabel?.text = String(contact.telephones[indexPath.row].number)
            cell.textLabel?.text = contact.telephones[indexPath.row].type
        } else {
            cell.textLabel?.text = "Não há nenhum telefone cadastrado!"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            //deletar telefone
          //  DAO().deleteTelephone(telephoneToDelete: contact.references[indexPath.row], contact: contact, index: indexPath.row)
            contact.references.remove(at: indexPath.row)
            telephonesTableView.reloadData()
        }
        
    }
    
}

