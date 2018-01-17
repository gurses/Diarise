//
//  ViewController.swift
//  Art Book
//
//  Created by Ahmet Malal on 16.01.2018.
//  Copyright © 2018 Ahmet Malal. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var nameArray = [String]()
    var yearArray = [Int]()
    var artistArray = [String]()
    var imageArray = [UIImage]()
    var dateArray = [String]()
    
    
    
    var selectedPainting = ""
    
    
    // uygulama ilk açıldığında açılıyor
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.orange
        tableView.delegate = self
        tableView.dataSource = self
        getInfo()
        
    }
    // uygulama her açıldığında açılıyor
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.getInfo), name: NSNotification.Name(rawValue: "newPainting"), object: nil)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            nameArray.remove(at: indexPath.row)
            yearArray.remove(at: indexPath.row)
            artistArray.remove(at: indexPath.row)
            imageArray.remove(at: indexPath.row)
            dateArray.remove(at: indexPath.row)
            tableView.deleteRows(at:[indexPath], with: UITableViewRowAnimation.fade)
            self.tableView.reloadData()
        }
    }
    @objc func getInfo()
    {
        nameArray.removeAll(keepingCapacity: false)
        dateArray.removeAll(keepingCapacity: false)
        yearArray.removeAll(keepingCapacity: false)
        imageArray.removeAll(keepingCapacity: false)
        artistArray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            let results = try context.fetch(fetchRequest)
            if results.count > 0 // gelen veri boş değilse
            {
                for result in results as![NSManagedObject]{
                    if let name = result.value(forKey: "name") as? String{
                        self.nameArray.append(name)
                    }
                    if let date = result.value(forKey: "date") as? String{
                        self.dateArray.append(date)
                    }
                    if let year = result.value(forKey: "year") as? Int{
                        self.yearArray.append(year)
                    }
                    if let artist = result.value(forKey: "artist") as? String{
                        self.artistArray.append(artist)
                    }
                    if let imageData = result.value(forKey: "image") as? Data{
                        let image = UIImage(data: imageData)
                        self.imageArray.append(image!)
                    }
                    self.tableView.reloadData()
                    
                    

                }
            }
            
        }catch{
            print("Error")
        }
        
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text=(dateArray[indexPath.row])
        return cell
    }
    
    // prepare for segue ve didselectRow lar viewController classları arasında bağlantı kuruyor obje-class ilişkisi gibi
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC"{
            let destinationVC = segue.destination as! detailedVC
            destinationVC.chosenPainting = selectedPainting
            
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         selectedPainting = dateArray[indexPath.row]
         performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    

    @IBAction func addButtonClicked(_ sender: Any) {
        selectedPainting  = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
        
    }
    
}

