//
//  ViewController.swift
//  CloudAula
//
//  Created by Andre Machado Parente on 01/02/17.
//  Copyright © 2017 Andre Machado Parente. All rights reserved.
//

import UIKit
import CloudKit

class ContactsVC: UIViewController {

    @IBOutlet weak var personsTableView: UITableView!
    var contactSelected: Contact!
    var activityIndicator = UIActivityIndicatorView()
    override func viewDidLoad() {
        super.viewDidLoad()
        personsTableView.delegate =  self
        personsTableView.dataSource = self
        print("original height:   ", self.navigationController?.navigationBar.frame.height, self.navigationController?.navigationBar.frame.maxY)
        
        self.navigationItem.title = "Contacts"
      
        //Activity Indicator
//        activityIndicator.startAnimating()
//        activityIndicator.activityIndicatorViewStyle = .whiteLarge
//        activityIndicator.color = UIColor.black
//        activityIndicator.hidesWhenStopped = true
//        activityIndicator.center = view.center
//    //    activityIndicator.frame = CGRect(x: view.frame.size.width/2, y: view.frame.size.height/2, width: view.frame.size.width/2, height: view.frame.size.width/2)
//        view.addSubview(activityIndicator)
//        
//        //Cloud
//        DAO().fetchContacts()
//        
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(ContactsVC.actOnNotificationSuccessFetchContacts), name: NSNotification.Name(rawValue: "notificationSuccessFetchContacts"), object: nil)
//
         NotificationCenter.default.addObserver(self, selector: #selector(ContactsVC.actOnNotificationSuccessCadastroContacts), name: NSNotification.Name(rawValue: "notificationSuccessCadastroContacts"), object: nil)
//        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addPerson(_ sender: UIBarButtonItem) {
        //adicionar uma pessoa. segue pra uma modal
        
        let alertController = UIAlertController(title: "Add New Contact", message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            
            let nameTextField = alertController.textFields![0] as UITextField
            let name = nameTextField.text
            
            let ageTextField = alertController.textFields![1] as UITextField
            let age = ageTextField.text
            
            if  name != "" && age != "" {
            print(name!, age!)
            
            //Salvar no cloud
            DAO().saveContact(contact: Contact(name: name!, idade: Int(age!)!))
            }
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Name"
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Age"
            textField.keyboardType = .numberPad
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        personsTableView.reloadData()
    }
    
    func actOnNotificationSuccessCadastroContacts() {
        
        DispatchQueue.main.async {
            self.personsTableView.reloadData()
        }
        
    }
    
    func actOnNotificationSuccessFetchContacts() {
        DispatchQueue.main.async {
            self.personsTableView.reloadData()
            self.activityIndicator.stopAnimating()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ContactsToTelephone" {
            let vc = segue.destination as! TelephoneVC
            vc.contact = contactSelected
        }
    }

}

extension ContactsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if globalContacts.count != 0 {
            return globalContacts.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = personsTableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        
        if globalContacts.count != 0 {
            cell.textLabel?.text = globalContacts[indexPath.row].name
            cell.detailTextLabel?.text = "Age: " + String(globalContacts[indexPath.row].idade)
            
        } else {
            cell.textLabel?.text = "Não há ninguém cadastrado!"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //segue pra outra TelephoneVC
        contactSelected = globalContacts[indexPath.row]
        self.performSegue(withIdentifier: "ContactsToTelephone", sender: self)
        
    }
}

