//
//  TaskCell.swift
//  Checkmate
//
//  Created by Mag isb-10 on 04/07/2024.
//

import UIKit

class TaskCell: UITableViewCell {
  @IBOutlet weak var radioImg: UIImageView!
  @IBOutlet weak var dateLbl: UILabel!
  @IBOutlet weak var taskLbl: UILabel!
  @IBOutlet weak var radioBtn: UIButton!
  @IBOutlet weak var reminderLbl: UILabel!
  @IBOutlet weak var reminderView: UIView!
  @IBOutlet weak var reminderImg: UIImageView!
  
  weak var delegate: TaskCellDelegate?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  @IBAction func taskCheckBtn(_ sender: UIButton) {
    delegate?.didTapCheckBtn(in: self)
    let haptic = UIImpactFeedbackGenerator(style: .heavy)
    haptic.impactOccurred()
  }
}
