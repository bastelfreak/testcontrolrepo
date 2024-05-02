#
# @summary demo profile to configure bolt
#
# @author Tim Meusel <tim@bastelfreak.de>
#
class profiles::test {
  bolt::project { 'peadmmig':
    plans => ['convert', 'upgrade'],
  }
}
