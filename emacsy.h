
/* Initialize Emacsy. */
int  emacsy_init(void);

/* Enqueue a keyboard event. */
void emacsy_key_event(int modifier_key_flags, 
                      int key_code);

/* Enqueue a mouse event. */
void emacsy_mouse_event(int x, int y, 
                        int button, int state);

/* Run an iteration of Emacsy's event loop 
   (will not block). */
void emacsy_tick(); 

/* Return the message or echo area. */
char *emacsy_message_or_echo_area();

/* Return the mode line */
char *emacsy_mode_line();
