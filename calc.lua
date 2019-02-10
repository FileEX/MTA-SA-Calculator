--[[
	Author: FileEX
]]

calc = {};
setmetatable(calc, {__call = function(o, ...) return o:constructor(...) end, __index = calc});

local win,edit,mc;

local buttons = {
	'1',
	'2',
	'3',
	'4',
	'5',
	'6',
	'7',
	'8',
	'9',
	'.',
	'=',
	'+',
	'-',
	'*',
	'/',
	'^',
	'%',
	'0',
};

function calc:constructor()
	self.__init = function()
		self.result = [[result = ]];
		self.displayed = false;
		self.editFocused = false;
	end

	self.insertCharacer = function(_,character)
		if character ~= '.' and self.result:sub(#self.result, #self.result) ~= '.' then
			self.result = self.result..' '..character;
		else
			self.result = self.result..character;
		end
	end

	self.bckSpc = function(k)
		if k == 'backspace' then
			self.result = self.result:sub(0,#self.result - 2);
		end
	end

	self.editChanged = function()
		if self.editFocused then
			local character = guiGetText(source):sub(#guiGetText(source), #guiGetText(source));
			if character ~= '1' and character ~= '2' and character ~= '3' and character ~= '4' and character ~= '5' and character ~= '6' and character ~= '7' and character ~= '8' and character ~= '9' and character ~= '0' and character ~= '+' and character ~= '-' and character ~= '*' and character ~= '/' and character ~= ',' and character ~= '%' and character ~= '^' and character ~= '=' then
				guiSetText(source, guiGetText(source):sub(0,#guiGetText(source) - 1));
			else
				if character ~= '=' then
					self:insertCharacer(character);
				end
			end

			if character == '=' and #guiGetText(source) > 0 then
				loadstring(self.result)();
				guiSetText(source, result);
				self.result = [[calc.result = result]];
				loadstring(self.result)();
				self.result = 'result = '..self.result;
			end
		end
	end

	self.buttonAction = function(btn, state)
		if btn == 'left' and state == 'up' then
			if getElementType(source) == 'gui-button' and not self.editFocused then
				if guiGetText(source) ~= 'MC' then
					if guiGetText(source) ~= '=' then
						self:insertCharacer(guiGetText(source));
						guiSetText(edit, self.result:gsub('result = ',''));
					else
						if #guiGetText(edit) > 0 then
							loadstring(self.result)();
							guiSetText(edit, result);
							self.result = [[calc.result = result]];
							loadstring(self.result)();
							self.result = 'result = '..self.result;
						end
					end
				else
					self.result = [[result = ]];
					guiSetText(edit, '');
				end
			end
			if getElementType(source) ~= 'gui-edit' then
				self.editFocused = false;
			else
				self.editFocused = true;
			end
		end
	end

	self.createUI = function()
		win = guiCreateWindow(0.25, 0.15, 0.50, 0.70, 'Kalkulator', true);
		edit = guiCreateEdit(0.25, 0.08, 0.40, 0.07, '', true, win);
		mc = guiCreateButton(0.25, 0.50, 0.30, 0.15, 'MC', true, win);

		for k,v in pairs(buttons) do
			local x = 0.01 + (k <= 9 and ((k - 1) * 0.10) or ((k % (k < 18 and 18 or k - 1) - ((k < 18 and k or k - 1) - ((k < 18 and k or k - 1) % 9))) * 0.10));
			local y = (k <= 9 and 0.20 or 0.35);
			guiCreateButton(x, y, 0.08, 0.08, v, true, win);
		end

		addEventHandler('onClientGUIClick', resourceRoot, self.buttonAction);
		addEventHandler('onClientGUIChanged', edit, self.editChanged);
		addEventHandler('onClientKey', root, self.bckSpc);

		showCursor(true);
	end

	self.destroyUI = function()
		removeEventHandler('onClientGUIChanged', edit, self.editChanged);
		win:destroy();

		removeEventHandler('onClientGUIClick', resourceRoot, self.buttonAction);
		removeEventHandler('onClientKey', root, self.bckSpc);

		showCursor(false);
	end

	self.display = function(_,display)
		self.displayed = display;

		if self.displayed then
			self:createUI();
		else
			self:destroyUI();
		end
	end

	self.__init();
	return self;
end

local CClass;

bindKey('F3','down', function(k,ks)
	if k == 'F3' and ks == 'down' then
		if not CClass then
			CClass = calc();
			CClass:display(true);
		else
			CClass:display(false);
			CClass = nil;
		end
	end
end);