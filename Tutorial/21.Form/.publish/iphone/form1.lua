function setup()
	local x = 0
	local y = 0
	local pForm = UI_Form(nil,	-- arg[1]:	�e�ƂȂ�UI�^�X�N�̃|�C���^
		7000,		-- arg[2]:	��\���v���C�I���e�B
		x, y,		-- arg[3,4]:	�\���ʒu
		"asset://form1.json",	-- arg[5]:	composit json�̃p�X
		false		-- arg[6]:	�r���t���O
	)
	--[[
		arg[6]:�r���t���O �́A�ȗ��\�ł��B
		�ȗ������ꍇ�� false �Ɠ��������ɂȂ�܂��B
	]]
	
	TASK_StageOnly(pForm)
end

function execute(deltaT)
end

function leave()
	TASK_StageClear()
end

function formX_onClose()
	syslog('----- form1.onClose() -----')
	sysLoad("asset://Form.lua")
end
