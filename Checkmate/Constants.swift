//
//  Constants.swift
//  Checkmate
//
//  Created by Mag isb-10 on 06/07/2024.
//

import Foundation

func formatDate(date: Date) -> String {
  let formatter = DateFormatter()
  formatter.dateFormat = "dd MMMM"
  return formatter.string(from: date)
}
