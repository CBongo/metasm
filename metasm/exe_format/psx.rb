#    This file is part of Metasm, the Ruby assembly manipulation suite
#    Copyright (C) 2006-2009 Yoann GUILLOT
#
#    Licence is LGPL, see LICENCE in the top-level directory


require 'metasm/exe_format/main'
require 'metasm/encode'
require 'metasm/decode'


module Metasm
# Playstation executable (PSX) file format
class PlaystationExe < ExeFormat
	class Header < SerialStruct
		str :id, 8
		word :text_off		# offset of text segment
		word :data_off		# offset of data segment
		word :pc0		# initial prog counter
		word :gp0		# initial global ptr
		word :t_addr	# load addr of text segment
		word :t_size	# size of text segment
		word :d_addr	# load addr of data segment
		word :d_size	# size of data segment
		word :b_addr	# address of bss segment
		word :b_size	# size of bss segment
		word :s_addr	# address of stack
		word :s_size	# size of stack
		word :savedSP	# saved stack ptr from exec()
		word :savedFP	# saved frame ptr from exec()
		word :savedGP	# saved global ptr from exec()
		word :savedRA	# saved return addr from exec()
		word :savedS0	# saved base reg from exec()
		str :licensor,60	# copyright notice
	end

  def decode_byte(edata = @encoded) edata.decode_imm(:u8 , @endianness) end
  def decode_half(edata = @encoded) edata.decode_imm(:u16, @endianness) end
  def decode_word(edata = @encoded) edata.decode_imm(:u32, @endianness) end
  def encode_byte(w) Expression[w].encode(:u8 , @endianness) end
  def encode_half(w) Expression[w].encode(:u16, @endianness) end
  def encode_word(w) Expression[w].encode(:u32, @endianness) end
  def sizeof_byte ; 1 ; end
  def sizeof_half ; 2 ; end
  def sizeof_word ; 4 ; end


	attr_accessor :header, :text

	def initialize(cpu=nil)
		@endianness = (cpu ? cpu.endianness : :little)
		@header = Header.new
		@text = EncodedData.new
		super(cpu)
	end

	def decode_header
		@encoded.ptr = 0
		@header = Header.decode(self)
	end

	def decode
		decode_header
		@encoded.ptr = 0x800 + @header.text_off
		@text = EncodedData.new << @encoded.read(@header.t_size)
    @text.add_export('start', @header.pc0)
	end

	def cpu_from_headers
		MIPS.new(:little)
	end

	def each_section
		yield @text, @header.t_addr
	end

	def get_default_entrypoints
		['start']
	end
	
# returns the address at which a given file offset would be mapped
# def addr_to_fileoff(addr)
#   addr - @header.t_addr + 0x800
# end

 # returns the file offset where a mapped byte comes from
# def fileoff_to_addr(foff)
#   foff - 0x800 + @header.t_addr
# end
#
# def shortname; "psx"; end

end
end
