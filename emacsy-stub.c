
/* emacsy-stub.c */

int  emacsy_init(void) { return 0; }

void emacsy_key_event(int modifier_key_flags, 
                      int key_code) { 
  extern int counter;
  /* Fake the primitive scheme functions. */
  if (key_code == '=') 
    counter++;
  else if (key_code == '-')
    counter--;
}

void emacsy_tick() { }

char *emacsy_message_or_echo_area() {
  return "No commands defined."; 
}

char *emacsy_mode_line() {
  return "-:%*-  Simplest Application Ever";
}
