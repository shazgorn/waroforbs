require 'swordsman'

class ElfSwordsman < Unit
  TYPE = :elf_swordsman
  def initialize(x, y, user)
    super(TYPE, x, y, user)
    @name = I18n.t('Swordsman') + ' ' + @id.to_s
  end
end
