//
//  SnapsViewController.swift
//  MedinaSnapchat
//
//  Created by Mac 08 on 7/06/23.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class SnapsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tablaSnaps: UITableView!
    var snaps: [Snap] = []

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if snaps.count == 0 {
            return 1
        } else {
            return snaps.count
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snap = snaps[indexPath.row]
        performSegue(withIdentifier: "versnapsegue", sender: snap)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if snaps.count == 0 {
            cell.textLabel?.text = "No tienes Snaps 😩"
        } else {
            let snap = snaps[indexPath.row]
            cell.textLabel?.text = snap.from
        }
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "versnapsegue" {
            if let snap = sender as? Snap {
                let siguienteVC = segue.destination as! VerSnapViewController
                siguienteVC.snap = snap
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tablaSnaps.delegate = self
        tablaSnaps.dataSource = self

        let snapsRef = Database.database().reference().child("usuarios").child((Auth.auth().currentUser?.uid)!).child("snaps")
        snapsRef.observe(DataEventType.childAdded) { (snapshot) in
            if let snapDict = snapshot.value as? [String: Any] {
                let snap = Snap()
                snap.imagenURL = snapDict["imagenURL"] as? String
                snap.audioURL = snapDict["audioURL"] as? String
                snap.descripcion = snapDict["descripcion"] as? String ?? ""
                snap.from = snapDict["from"] as? String
                snap.id = snapshot.key
                snap.imagenID = snapDict["imagenID"] as? String
                snap.audioID = snapDict["audioID"] as? String

                self.snaps.append(snap)
                self.tablaSnaps.reloadData()
            }
        }

        snapsRef.observe(DataEventType.childRemoved) { (snapshot) in
            var iterator = 0
            for snap in self.snaps {
                if snap.id == snapshot.key {
                    self.snaps.remove(at: iterator)
                    break
                }
                iterator += 1
            }
            self.tablaSnaps.reloadData()
        }
    }

    @IBAction func cerrarSesionTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
