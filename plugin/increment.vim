" File: increment.vim
" Author: Srinath Avadhanula
" Email: srinath@eecs.berkeley.edu
"
" this is yet another script to create incremented lists. the usage is very
" intuitive because you visually select the block of numbers to be incremented
" instead of running search/replace commands, which is ofcourse not bad too,
" but still... to be honest, i remember seeing a script very similar to this
" somewhere... i ran a google search with "increment list vim", but couldnt
" unearth it... hence made this script.  
" 
" to illustrate the use, suppose you want to initialize the first 7 elements
" of a (matlab) array with the first 7 multiples of 3, you can do the
" following
" 
" 1. first type in the first line as
"     array(1) = 3
" 2. yank and paste 6 times
"     yy6p
" 3. then using control-v, you select the column of '1's. press control-v
"    again to leave visual mode (this still retains the < and the > marks)
" 4. run the command utility:
"     :Inc
" 5. repeat the selection-deselection with the column of '3's.
" 6. this time run the command
"     :Inc 3
" voila! (okay so 6 steps is not exactly voila material, but it still saves you a lot of key-presses)
" 
" Note: the command Inc is "smart" in the sense that it pads the column with
" leading zeros if the list consists of numbers with unequal number of
" digits. If you do not want this, (for example if the number is the suffix
" of a variable name), then use the command "IncN" instead of "Inc"
" 
" a nifty mapping which goes well with this command is the following:
" 
" vnoremap <c-a> <c-v>:Inc 1<cr>
" 
" with this mapping, you can select a block of numbers and press control-a in
" visual mode and you get an incremented list of numbers.  (this is very
" similar to the control-a command in normal mode which increments the number
" under the cursor)

function! StrRepeat(str, count)
	let i = 1
	let retStr = ""
	while i <= a:count
		let retStr = retStr.a:str
		let i = i + 1
	endwhile
	return retStr
endfunction

" first argument is either 0 or 1 depending on whether padding with leading
" spaces is desired (pad = 1) or not. the second argument contains the counter
" increment. its optional. if not specified, its assumed to be 1.
function! IncrementColumn(pad, ...)
	if a:0 == 0
		let incr = 1
	elseif a:0 == 1
		let incr = a:1
	else
		return
	end

	let c1 = col("'<")
	let c2 = col("'>")
	let r1 = line("'<")
	let r2 = line("'>")

	normal `<
	exe "let presNum = ".strpart(getline('.'), c1-1, c2-c1+1)
	let lastnum = presNum + incr*(r2-r1)
	" a simple way to find the number of digits in a number
	let maxstrlen = strlen("".lastnum)

	let r = r1
	while (r <= r2)
		let linebef = strpart(getline('.'), 0, c1-1)
		let lineaft = strpart(getline('.'), c2, 1000)

		" find the number of padding spaces required for left alignment
		if a:pad
			let preslen = strlen("".presNum)
			let padspace = StrRepeat(" ", maxstrlen - preslen)
		else
			let padspace = ""
		end

		" the final line is made up of 
		" 1. the part of the line before the number
		" 2. the padding spaces.
		" 3. the present number
		" 4. the part of the line after the number
		let lineset = linebef.padspace.presNum.lineaft
		call setline('.', lineset)
		let presNum = presNum + incr
		normal j
		let r = r + 1
	endwhile
	normal `<
endfunction

com! -nargs=? Inc :call IncrementColumn(1,<args>)
com! -nargs=? IncN :call IncrementColumn(0,<args>)


