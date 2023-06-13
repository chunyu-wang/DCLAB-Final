all: tb/*.sv *.sv
	vcs tb/tb_VGA.sv VGA.sv -full64 -R -debug_access+all +v2k -sverilog
game: tb/tb_Game.sv *.sv	
	vcs tb/tb_Game.sv GameLogic.sv -full64 -R -debug_access+all +v2k -sverilog