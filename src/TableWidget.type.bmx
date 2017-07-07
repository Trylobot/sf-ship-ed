
Global JUSTIFY_LEFT% = 0
Global JUSTIFY_RIGHT% = 1


Type TableWidget

  Field cells$[][]
  Field rows%
  Field cols%
  Field align%[] ' default: 0  (JUSTIFY_LEFT)

  
  Method resize( rows_count%, cols_count% )
    rows = rows_count
    cols = cols_count
    cells = new String[][rows_count]
    For Local r% = 0 Until rows_count
      cells[r] = New String[cols_count]
    Next
    align = New Int[cols_count]
  EndMethod

  Method justify_col( c%, j% )' j = { JUSTIFY_LEFT | JUSTIFY_RIGHT }
    align[c] = j
  EndMethod
  
  Method set_cell( r%, c%, value$ )
    cells[r][c] = value
  EndMethod

  Method to_TextWidget:TextWidget()
    ' determine width for each column
    Local widths%[] = New Int[cols]
    For Local c% = 0 Until cols
      widths[c] = 0
      For Local r% = 0 Until rows
        widths[c] = Max( widths[c], cells[r][c].length )
      Next
    Next
    ' pad each cell to the width of the longest cell in that column
    For Local c% = 0 Until cols
      For Local r% = 0 Until rows
        If align[c] = JUSTIFY_LEFT
          cells[r][c] = LSet(cells[r][c], widths[c])
        ElseIf align[c] = JUSTIFY_RIGHT
          cells[r][c] = RSet(cells[r][c], widths[c])
        EndIf
      Next
    Next
    ' render each row to a string, in order, padding each cell division
    Local lines$[] = New String[rows]
    For Local r% = 0 Until rows
      lines[r] = " ".Join(cells[r])
    Next
    ' 
    return TextWidget.Create( lines )
  EndMethod

EndType
