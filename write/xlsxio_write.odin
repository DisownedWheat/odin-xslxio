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
* @file xlsxio_write.h
* @brief XLSX I/O header file for writing .xlsx files.
* @author Brecht Sanders
* @date 2016
* @copyright MIT
*
* Include this header file to use XLSX I/O for writing .xlsx files and
* link with -lxlsxio_write.
*/
package write

import "core:c"
import "core:c/libc"

_ :: c
_ :: libc

LOCAL :: #config(LOCAL, true)
STATIC :: #config(STATIC, false)

when ODIN_OS == .Linux {
	when LOCAL {
		foreign import lib {"../lib/linux/libxlsxio_write.a", "../lib/linux/libzip.a", "../lib/linux/libz.a"}
	} else {
		when STATIC {
			foreign import lib {"../lib/linux/libxlsxio_write.a", "system:libzip.a", "system:libz.a"}
		} else {
			foreign import lib {"../lib/linux/libxlsxio_write.a", "system:libzip.so", "system:libz.so"}
		}
	}
}

when ODIN_OS == .Windows {
	foreign import lib "../lib/windows/libxlsxio_write.a"
}

/*! \brief write handle for .xlsx object */
xlsxiowriter :: struct {}

@(default_calling_convention = "c", link_prefix = "xlsxiowrite_")
foreign lib {
	/*! \brief get xlsxio_write version
	* \param  pmajor        pointer to integer that will receive major version number
	* \param  pminor        pointer to integer that will receive minor version number
	* \param  pmicro        pointer to integer that will receive micro version number
	* \sa     get_version_string()
	*/
	get_version :: proc(pmajor: ^c.int, pminor: ^c.int, pmicro: ^c.int) ---

	/*! \brief get xlsxio_write version string
	* \return version string
	* \sa     get_version()
	*/
	get_version_string :: proc() -> cstring ---

	/*! \brief create and open .xlsx file
	* \param  filename      path of .xlsx file to open
	* \param  sheetname     name of worksheet
	* \return write handle for .xlsx object or NULL on error
	* \sa     close()
	*/
	open :: proc(filename: cstring, sheetname: cstring) -> xlsxiowriter ---

	/*! \brief close .xlsx file
	* \param  handle        write handle for .xlsx object
	* \return zero on success, non-zero on error
	* \sa     open()
	*/
	close :: proc(handle: xlsxiowriter) -> c.int ---

	/*! \brief specify how many initial rows will be buffered in memory to determine column widths
	* \param  handle        write handle for .xlsx object
	* \param  rows          number of rows to buffer in memory, zero for none
	* Must be called before the first call to next_row()
	* \sa     add_column()
	* \sa     next_row()
	*/
	set_detection_rows :: proc(handle: xlsxiowriter, rows: c.size_t) ---

	/*! \brief specify the row height to use for the current and next rows
	* \param  handle        write handle for .xlsx object
	* \param  height        row height (in text lines), zero for unspecified
	* Must be called before the first call to any add_ function of the current row
	* \sa     next_row()
	*/
	set_row_height :: proc(handle: xlsxiowriter, height: c.size_t) ---

	/*! \brief add a column cell
	* \param  handle        write handle for .xlsx object
	* \param  name          column name
	* \param  width         column width (in characters)
	* Only one row of column names is supported or none.
	* Call for each column, and finish column row by calling next_row().
	* Must be called before any next_row() or the add_cell_ functions.
	* \sa     next_row()
	* \sa     set_detection_rows()
	*/
	add_column :: proc(handle: xlsxiowriter, name: cstring, width: c.int) ---

	/*! \brief add a cell with string data
	* \param  handle        write handle for .xlsx object
	* \param  value         string value
	* \sa     next_row()
	*/
	add_cell_string :: proc(handle: xlsxiowriter, value: cstring) ---

	/*! \brief add a cell with integer data
	* \param  handle        write handle for .xlsx object
	* \param  value         integer value
	* \sa     next_row()
	*/
	add_cell_int :: proc(handle: xlsxiowriter, value: i64) ---

	/*! \brief add a cell with floating point data
	* \param  handle        write handle for .xlsx object
	* \param  value         floating point value
	* \sa     next_row()
	*/
	add_cell_float :: proc(handle: xlsxiowriter, value: f64) ---

	/*! \brief add a cell with date and time data
	* \param  handle        write handle for .xlsx object
	* \param  value         date and time value
	* \sa     next_row()
	*/
	add_cell_datetime :: proc(handle: xlsxiowriter, value: libc.time_t) ---

	/*! \brief mark the end of a row (next cell will start on a new row)
	* \param  handle        write handle for .xlsx object
	* \sa     add_cell_string()
	*/
	next_row :: proc(handle: xlsxiowriter) ---
}
