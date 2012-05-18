

#include <GLUT/glut.h> 
#include <stdlib.h>
#include <libguile.h>
#include "emacsy.h"

void draw_string(int, int, char*);

int counter = 0; /* We display this number. */

void keyboard_func(unsigned char key, 
                   int x, int y) {
 if (key == 'q')
    exit(0);
  /* Send the key event to Emacsy 
     (not processed yet). */
  emacsy_key_event(glutGetModifiers(), key);
  glutPostRedisplay();
}

/* GLUT display function */
void display_func() {
  
  glClear(GL_COLOR_BUFFER_BIT);

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glOrtho(0.0, 500.0, 0.0, 500.0, -2.0, 500.0);
  gluLookAt(0, 0, 2, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);

  glMatrixMode(GL_MODELVIEW);
  glColor3f(1,1,1);
  
  
  char counter_string[255];
  sprintf(counter_string, "%d", counter);
  draw_string(250, 250, counter_string);
  

  /* Process events in Emacsy. */
  emacsy_tick();

  /* Display Emacsy message/echo area. */
  draw_string(0, 5, emacsy_message_or_echo_area());
  /* Display Emacsy mode line. */
  draw_string(0, 30, emacsy_mode_line());
        
  glutSwapBuffers();
}

SCM_DEFINE (get_counter, "get-counter", 
                 /* required arg count    */ 0,
                 /* optional arg count    */ 0,
                 /* variable length args? */ 0,
                 (),
                 "Returns value of counter.")
{
  return scm_from_int(counter);
}

SCM_DEFINE (set_counter_x, "set-counter!", 
                 /* required arg count    */ 1,
                 /* optional arg count    */ 0,
                 /* variable length args? */ 0,
                 (SCM value),
                 "Sets value of counter.")
{
  counter = scm_to_int(value);
  return SCM_UNSPECIFIED;
}

/* Draws a string at (x, y) on the screen. */
void draw_string(int x, int y, char *string) {
  glLoadIdentity();
  glTranslatef(x, y, 0.);
  glScalef(0.2, 0.2, 1.0);
  while(*string) 
    glutStrokeCharacter(GLUT_STROKE_ROMAN, 
                        *string++);
}


int main(int argc, char *argv[]) {
  
  glutInit(&argc, argv);
  glutInitDisplayMode(GLUT_RGB|GLUT_DOUBLE);
  glutInitWindowSize(500, 500);
  glutCreateWindow("Minimal Emacsy Example");
  glutDisplayFunc(display_func);
  glutKeyboardFunc(keyboard_func);
  
  scm_init_guile(); /* Initialize Guile.  */
  emacsy_init();    /* Initialize Emacsy. */
  /* Load config. */
  //scm_c_primitive_load(".hello_emacsy"); 
  glutMainLoop();   /* We never return.   */
  return 0; 
}

