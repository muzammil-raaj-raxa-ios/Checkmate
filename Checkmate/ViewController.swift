//
//  ViewController.swift
//  Checkmate
//
//  Created by Mag isb-10 on 04/07/2024.
//

import UIKit

protocol TaskCellDelegate: AnyObject {
  func didTapCheckBtn(in cell: TaskCell)
}

class ViewController: UIViewController, TaskCellDelegate {
  @IBOutlet weak var tasksTblView: UITableView!
  @IBOutlet weak var addBtn: UIButton!
  @IBOutlet weak var noTaskView: UIView!
  
  var tasks: [TaskModel] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tasksTblView.delegate = self
    tasksTblView.dataSource = self
    tasksTblView.register(UINib(nibName: "TaskCell", bundle: .main), forCellReuseIdentifier: "TaskCell")
    
    addBtn.setTitle("", for: .normal)
    noTaskView.isHidden = true
    tasksTblView.reloadData()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    noTaskView.isHidden = tasks.count > 0
  }
  
  @IBAction func addTaskBtn(_ sender: Any) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    guard let vc = storyboard.instantiateViewController(withIdentifier: "AddTaskVC") as? AddTaskVC else {return}
    vc.delegate = self
    if #available(iOS 15.0, *) {
      if let sheet = vc.sheetPresentationController {
        sheet.preferredCornerRadius = 20
        sheet.detents = [.medium()]
      } else {
        vc.modalPresentationStyle = .pageSheet
      }
    }
    
    present(vc, animated: true)
    print("add task btn pressed")
  }
  
  func didTapCheckBtn(in cell: TaskCell) {
    if let indexpath = tasksTblView.indexPath(for: cell) {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        self.tasks.remove(at: indexpath.row)
        self.tasksTblView.deleteRows(at: [indexpath], with: .fade)
      }
    }
    
    if cell.radioImg.image == UIImage(named: "radioBtnRed") {
      cell.radioImg.image = UIImage(named: "radioBtnWhite")
    } else {
      cell.radioImg.image = UIImage(named: "radioBtnRed")
    }
    
    noTaskView.isHidden = tasks.count > 0
  }
  
  func addTask(_ task: TaskModel) {
    tasks.append(task)
    DispatchQueue.main.async {
      self.tasksTblView.reloadData()
      self.noTaskView.isHidden = self.tasks.count > 0
    }
  }
  
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tasks.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell else { return UITableViewCell()}
    
    let item = tasks[indexPath.row]
    cell.delegate = self
    cell.dateLbl.text = item.taskDate
    cell.radioImg.image = item.radioImg
    cell.taskLbl.text = item.taskName
    
    if item.reminderTime == "" {
      cell.reminderView.isHidden = true
    } else {
      cell.reminderView.isHidden = false
      cell.reminderLbl.text = item.reminderTime
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 70
  }
}
