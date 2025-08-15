/*****************************************************************************
Copyright (C)  2016  Brecht Sanders  All Rights Reserved

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*****************************************************************************/
/**
* @file xlsxio_read.h
* @brief XLSX I/O header file for reading .xlsx files.
* @author Brecht Sanders
* @date 2016
* @copyright MIT
*
* Include this header file to use XLSX I/O for reading .xlsx files and
* link with -lxlsxio_read.
* This header provides both advanced methods using callback functions and
* simple methods for iterating through data.
*/
package read

import "core:c"
import "core:c/libc"

_ :: c

when ODIN_OS == .Linux {
	foreign import lib {"../lib/libxlsxio_read.a", "../lib/libzip.a", "../lib/libz.a", "../lib/libexpat.a"}
}

XLSXIOCHAR :: c.char

/*! \brief read handle for .xlsx object */
xlsxioreader :: struct {}

/*! \brief type of pointer to callback function for listing worksheets
* \param  name          name of worksheet
* \param  callbackdata  callback data passed to xlsxioread_list_sheets
* \return zero to continue, non-zero to abort
* \sa     xlsxioread_list_sheets()
*/
list_sheets_callback_fn :: proc "c" (_: cstring, _: rawptr) -> c.int

/*! \brief don't skip any rows or cells \hideinitializer */
XLSXIOREAD_SKIP_NONE :: 0

/*! \brief skip empty rows (note: cells may appear empty while they actually contain data) \hideinitializer */
XLSXIOREAD_SKIP_EMPTY_ROWS :: 0x01

/*! \brief skip empty cells \hideinitializer */
XLSXIOREAD_SKIP_EMPTY_CELLS :: 0x02

/*! \brief skip empty rows and cells \hideinitializer */
XLSXIOREAD_SKIP_ALL_EMPTY :: XLSXIOREAD_SKIP_EMPTY_ROWS | XLSXIOREAD_SKIP_EMPTY_CELLS

/*! \brief skip extra cells to the right of the rightmost header cell \hideinitializer */
XLSXIOREAD_SKIP_EXTRA_CELLS :: 0x04

/*! \brief skip hidden rows \hideinitializer */
XLSXIOREAD_SKIP_HIDDEN_ROWS :: 0x08

/*! \brief type of pointer to callback function for processing a worksheet cell value
* \param  row           row number (first row is 1)
* \param  col           column number (first column is 1)
* \param  value         value of cell (note: formulas are not calculated)
* \param  callbackdata  callback data passed to xlsxioread_process
* \return zero to continue, non-zero to abort
* \sa     xlsxioread_process()
* \sa     xlsxioread_process_row_callback_fn
*/
process_cell_callback_fn :: proc "c" (_: c.size_t, _: c.size_t, _: cstring, _: rawptr) -> c.int

/*! \brief type of pointer to callback function for processing the end of a worksheet row
* \param  row           row number (first row is 1)
* \param  maxcol        maximum column number on this row (first column is 1)
* \param  callbackdata  callback data passed to xlsxioread_process
* \return zero to continue, non-zero to abort
* \sa     xlsxioread_process()
* \sa     xlsxioread_process_cell_callback_fn
*/
process_row_callback_fn :: proc "c" (_: c.size_t, _: c.size_t, _: rawptr) -> c.int

/*! \brief read handle for list of worksheet names */
xlsxioreadersheetlist :: struct {}

/*! \brief read handle for worksheet object */
xlsxioreadersheet :: struct {}

@(default_calling_convention = "c", link_prefix = "xlsxioread_")
foreign lib {
	/*! \brief get xlsxio_write version
	* \param  pmajor        pointer to integer that will receive major version number
	* \param  pminor        pointer to integer that will receive minor version number
	* \param  pmicro        pointer to integer that will receive micro version number
	* \sa     xlsxiowrite_get_version_string()
	*/
	get_version :: proc(pmajor: ^c.int, pminor: ^c.int, pmicro: ^c.int) ---

	/*! \brief get xlsxio_write version string
	* \return version string
	* \sa     xlsxiowrite_get_version()
	*/
	get_version_string :: proc() -> cstring ---

	/*! \brief open .xlsx file
	* \param  filename      path of .xlsx file to open
	* \return read handle for .xlsx object or NULL on error
	* \sa     close()
	*/
	open :: proc(filename: cstring) -> ^xlsxioreader ---

	/*! \brief open .xlsx file
	* \param  filehandle    file handle of .xlsx file opened with read access in binary mode
	* \return read handle for .xlsx object or NULL on error
	* \sa     close()
	*/
	open_filehandle :: proc(filehandle: c.int) -> ^xlsxioreader ---

	/*! \brief open .xlsx from memory buffer
	* \param  data          memory buffer containing .xlsx file (data must remain valid as long as any  functions are called)
	* \param  datalen       size of memory buffer containing .xlsx file
	* \param  freedata      if non-zero data will be freed by close()
	* \return read handle for .xlsx object or NULL on error
	* \sa     close()
	*/
	open_memory :: proc(data: rawptr, datalen: u64, freedata: c.int) -> ^xlsxioreader ---

	/*! \brief close .xlsx file
	* \param  handle        read handle for .xlsx object
	* \sa     open()
	*/
	close :: proc(handle: ^xlsxioreader) ---

	/*! \brief list worksheets in .xlsx file
	* \param  handle        read handle for .xlsx object
	* \param  callback      callback function called for each worksheet
	* \param  callbackdata  custom data as passed to quickmail_add_body_custom/quickmail_add_attachment_custom
	* \sa     list_sheets_callback_fn
	*/
	list_sheets :: proc(handle: ^xlsxioreader, callback: list_sheets_callback_fn, callbackdata: rawptr) ---

	/*! \brief process all rows and columns of a worksheet in an .xlsx file
	* \param  handle        read handle for .xlsx object
	* \param  sheetname     worksheet name (NULL for first sheet)
	* \param  flags         SKIP_ flag(s) to determine how data is processed
	* \param  cell_callback callback function called for each cell
	* \param  row_callback  callback function called after each row
	* \param  callbackdata  callback data passed to process
	* \return zero on success, non-zero on error
	* \sa     process_row_callback_fn
	* \sa     process_cell_callback_fn
	*/
	process :: proc(handle: ^xlsxioreader, sheetname: cstring, flags: c.uint, cell_callback: process_cell_callback_fn, row_callback: process_row_callback_fn, callbackdata: rawptr) -> c.int ---

	/*! \brief open list of worksheet names
	* \param  handle           read handle for .xlsx object
	* \sa     sheetlist_close()
	* \sa     open()
	*/
	sheetlist_open :: proc(handle: ^xlsxioreader) -> ^xlsxioreadersheetlist ---

	/*! \brief close worksheet
	* \param  sheetlisthandle  read handle for worksheet object
	* \sa     sheetlist_open()
	*/
	sheetlist_close :: proc(sheetlisthandle: ^xlsxioreadersheetlist) ---

	/*! \brief get next worksheet name
	* \param  sheetlisthandle  read handle for worksheet object
	* \return name of worksheet or NULL if no more worksheets are available
	* \sa     sheetlist_open()
	*/
	sheetlist_next :: proc(sheetlisthandle: ^xlsxioreadersheetlist) -> cstring ---

	/*! \brief get index of last row read from worksheet (returns 0 if no row was read yet)
	* \param  sheethandle   read handle for worksheet object
	* \sa     sheet_open()
	*/
	sheet_last_row_index :: proc(sheethandle: ^xlsxioreadersheet) -> c.size_t ---

	/*! \brief get index of last column read from current row in worksheet (returns 0 if no column was read yet)
	* \param  sheethandle   read handle for worksheet object
	* \sa     sheet_open()
	*/
	sheet_last_column_index :: proc(sheethandle: ^xlsxioreadersheet) -> c.size_t ---

	/*! \brief get flags used to open worksheet
	* \param  sheethandle   read handle for worksheet object
	* \sa     sheet_open()
	*/
	sheet_flags :: proc(sheethandle: ^xlsxioreadersheet) -> c.uint ---

	/*! \brief open worksheet
	* \param  handle        read handle for .xlsx object
	* \param  sheetname     worksheet name (NULL for first sheet)
	* \param  flags         SKIP_ flag(s) to determine how data is processed
	* \return read handle for worksheet object or NULL in case of error
	* \sa     sheet_close()
	* \sa     open()
	*/
	sheet_open :: proc(handle: ^xlsxioreader, sheetname: cstring, flags: c.uint) -> ^xlsxioreadersheet ---

	/*! \brief close worksheet
	* \param  sheethandle   read handle for worksheet object
	* \sa     sheet_open()
	*/
	sheet_close :: proc(sheethandle: ^xlsxioreadersheet) ---

	/*! \brief get next row from worksheet (to be called before each row)
	* \param  sheethandle   read handle for worksheet object
	* \return non-zero if a new row is available
	* \sa     sheet_open()
	*/
	sheet_next_row :: proc(sheethandle: ^xlsxioreadersheet) -> c.int ---

	/*! \brief get next cell from worksheet
	* \param  sheethandle   read handle for worksheet object
	* \return value (caller must free the result using free()) or NULL if no more cells are available in the current row
	* \sa     sheet_open()
	* \sa     free()
	*/
	sheet_next_cell :: proc(sheethandle: ^xlsxioreadersheet) -> cstring ---

	/*! \brief get next cell from worksheet as a string
	* \param  sheethandle   read handle for worksheet object
	* \param  pvalue        pointer where string will be stored if data is available (caller must free the result using free())
	* \return non-zero if a new cell was available in the current row
	* \sa     sheet_open()
	* \sa     sheet_next_cell()
	* \sa     free()
	*/
	sheet_next_cell_string :: proc(sheethandle: ^xlsxioreadersheet, pvalue: [^]cstring) -> c.int ---

	/*! \brief get next cell from worksheet as an integer
	* \param  sheethandle   read handle for worksheet object
	* \param  pvalue        pointer where integer will be stored if data is available
	* \return non-zero if a new cell was available in the current row
	* \sa     sheet_open()
	* \sa     sheet_next_cell()
	*/
	sheet_next_cell_int :: proc(sheethandle: ^xlsxioreadersheet, pvalue: ^i64) -> c.int ---

	/*! \brief get next cell from worksheet as a floating point value
	* \param  sheethandle   read handle for worksheet object
	* \param  pvalue        pointer where floating point value will be stored if data is available
	* \return non-zero if a new cell was available in the current row
	* \sa     sheet_open()
	* \sa     sheet_next_cell()
	*/
	sheet_next_cell_float :: proc(sheethandle: ^xlsxioreadersheet, pvalue: ^f64) -> c.int ---

	/*! \brief get next cell from worksheet as date and time data
	* \param  sheethandle   read handle for worksheet object
	* \param  pvalue        pointer where date and time data will be stored if data is available
	* \return non-zero if a new cell was available in the current row
	* \sa     sheet_open()
	* \sa     sheet_next_cell()
	*/
	sheet_next_cell_datetime :: proc(sheethandle: ^xlsxioreadersheet, pvalue: ^libc.time_t) -> c.int ---

	/*! \brief free memory allocated by the library
	* \param  data          memory to be freed
	* \sa     sheet_next_cell()
	* \sa     sheet_next_cell_string()
	*/
	free :: proc(data: cstring) ---
}
