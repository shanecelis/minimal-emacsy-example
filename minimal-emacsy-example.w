% hello.w
 
\documentclass[a4paper,twocolumn]{article}
\newif\ifshowcode
\showcodetrue
%\usepackage{multicol}
\usepackage{latexsym}
%\usepackage{html}

\usepackage{listings}
\usepackage{graphicx}

\usepackage{color}
%\usepackage{framed}
\usepackage{textcomp}
%\definecolor{listinggray}{gray}{0.9}
%\definecolor{shadecolor}{HTML}{211e1e}
\lstset{
	tabsize=2,
	language=C,
    keepspaces=true,
    upquote=true,
    aboveskip=0pt,
    belowskip=0pt,
    framesep=0pt,
    rulesep=0pt,
    columns=fixed,
    showstringspaces=true,
    extendedchars=true,
    breaklines=true,
    prebreak = \raisebox{0ex}[0ex][0ex]{\ensuremath{\hookleftarrow}},
    frame=none,
    framerule=0pt,
    showtabs=false,
    showspaces=false,
    showstringspaces=false,
    %basicstyle=\color[HTML]{dadada},
	  %rulecolor=\color[HTML]{dadada},
	  %backgroundcolor=\color[HTML]{211E1E},
    %identifierstyle=\color[HTML]{bec337},%\ttfamily,
    %keywordstyle=\color[HTML]{6f61ff},
    %commentstyle=\color[HTML]{ED5B15},
    %stringstyle=\color[HTML]{ad9361}
}
%% \usepackage{minted}
%% \usemintedstyle{monokai}
%% \definecolor{bg}{RGB}{39,40,34}

\definecolor{linkcolor}{rgb}{0, 0, 0.7}
\usepackage[backref,raiselinks,pdfhighlight=/O,pagebackref,hyperfigures,breaklinks,colorlinks,pdfstartview=FitBH,linkcolor={linkcolor},anchorcolor={linkcolor},citecolor={linkcolor},filecolor={linkcolor},menucolor={linkcolor},pagecolor={linkcolor},urlcolor={linkcolor}]{hyperref}
\NWuseHyperlinks
%\renewcommand{\NWtarget}[2]{\hypertarget{#1}{#2}}
%\renewcommand{\NWlink}[2]{\hyperlink{#1}{#2}} 
\renewcommand{\NWtxtDefBy}{defined by}
\renewcommand{\NWtxtRefIn}{referenced in}
\renewcommand{\NWtxtNoRef}{not referenced}
\renewcommand{\NWtxtIdentsUsed}{Fragment uses}
\renewcommand{\NWtxtIdentsNotUsed}{(never used)}
\renewcommand{\NWtxtIdentsDefed}{Fragment defines}

\setlength{\oddsidemargin}{0in}
\setlength{\evensidemargin}{0in}
\setlength{\topmargin}{0in}
\addtolength{\topmargin}{-\headheight}
\addtolength{\topmargin}{-\headsep}
\setlength{\textheight}{8.9in}
\setlength{\textwidth}{6.5in}
\setlength{\marginparwidth}{0.5in}

\title{Minimal Emacsy Example Program}
\date{}
\author{Shane Celis
\\ {\sl shane.celis@@gmail.com}}

\begin{document}
\maketitle
%\begin{multicols}{2}

\section{Introduction}
I have received a lot of questions asking, what does
Emacsy\footnote{Kickstarter page \url{http://kck.st/IY0Bau}} actually do?  What
restrictions does it impose on the GUI toolkit?  How is it possible to
not use any Emacs code? I thought it might be best if I were to
provide a minimal example program, so that people can see code that
illustrates Emacsy API usage.

\section{Embedders' API}

These are the proposed function prototypes defined in \verb|emacsy.h|.

@o emacsy.h -cc @{@% 
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
char *emacsy_mode_line();@%
@|@}

\section{The Simplest Application Ever}

Let's exercise these functions in a minimal GLUT program we'll call
\verb|hello-emacsy|.  Note: Emacsy does not rely on GLUT; you could
use Qt, Cocoa or ncurses.  This program will display an integer, the
variable \verb|counter|.

@o hello-emacsy.c @{@%
@< Include Headers @>
int counter = 0; /* We display this number. */
@< Functions @>
@< Main @>@%
@|@}

Let's start with the main function.

@d Main @{@%
int main(int argc, char *argv[]) {
  @< GLUT Initialization @>
  scm_init_guile(); /* Initialize Guile.  */
  emacsy_init();    /* Initialize Emacsy. */
  /* Load config. */
  //scm_c_primitive_load(".hello_emacsy"); 
  glutMainLoop();   /* We never return.   */
  return 0; 
}@%
@|@}

\begin{figure} 
  \centering
  \includegraphics[scale=0.4]{../minimal-emacsy-example.pdf} 
  \caption[Short Label]{\label{../minimal-emacsy-example.pdf}Emacsy
    integrated into the simplest application ever!}
\end{figure} 


\section{Runloop Interaction}

Let's look at how Emacsy interacts with your application's runloop
since that's probably the most concerning part of embedding.  First,
let's pass some input to Emacsy.

@d Functions @{@%
void keyboard_func(unsigned char key, 
                   int x, int y) {
 if (key == 'q')
    exit(0);
  /* Send the key event to Emacsy 
     (not processed yet). */
  emacsy_key_event(glutGetModifiers(), key);
  glutPostRedisplay();
}@%
@|@}

The function \verb|display_func| is run for every frame that's
drawn. It's effectively our runloop.

%(The actual runloop is in GLUT, so \verb|display_func| is effectively
%our runloop.)

@d Functions @{@%
/* GLUT display function */
void display_func() {
  @< Display Setup @>
  @< Display the counter variable @>

  /* Process events in Emacsy. */
  emacsy_tick();

  /* Display Emacsy message/echo area. */
  draw_string(0, 5, emacsy_message_or_echo_area());
  /* Display Emacsy mode line. */
  draw_string(0, 30, emacsy_mode_line());
        
  glutSwapBuffers();
}@%
@|@}

At this point, our application can process key events, accept input on
the minibuffer, and use nearly all of the facilities that Emacsy
offers, but it can't change any application state, which makes it not
very interesting yet.

\section{Plugging Into Your App}

Let's define a new primitive Scheme procedure \verb|get-counter|, so
Emacsy can access the application's internal state.
@d Functions @{@%
SCM_DEFINE (get_counter, "get-counter", 
                 /* required arg count    */ 0,
                 /* optional arg count    */ 0,
                 /* variable length args? */ 0,
                 (),
                 "Returns value of counter.")
{
  return scm_from_int(counter);
}@%
@|@}
Let's define another primitive Scheme procedure to alter the
application's internal state.
@d Functions @{@%
SCM_DEFINE (set_counter_x, "set-counter!", 
                 /* required arg count    */ 1,
                 /* optional arg count    */ 0,
                 /* variable length args? */ 0,
                 (SCM value),
                 "Sets value of counter.")
{
  counter = scm_to_int(value);
  return SCM_UNSPECIFIED;
}@%
@|@}

Emacsy can now access and alter the application's internal state.

\section{Changing the UI}
Now let's use these new procedures to create interactive commands and
bind them to keys by changing our config file \verb|.hello-emacsy|.

@o .hello-emacsy -cl @{@%
(define-interactive (incr-counter)
 (set-counter! (1+ (get-counter))))

(define-interactive (decr-counter)
 (set-counter! (1- (get-counter))))

(define-key global-map 
 (kbd "+") 'incr-counter)
(define-key global-map 
 (kbd "-") 'decr-counter)@%
@|@}

This is fine, but what else can we do with it?  Let's implement
another command that will ask the user for a number to set the counter
to.

@o .hello-emacsy @{@%
(define-interactive (change-counter) 
 (set-counter! 
  (read-from-minibuffer "New counter value: ")))@%
@|@}

Now we can hit \verb|M-x change-counter| and we'll be prompted for the
new value we want.  There we have it.  We have made the simplest
application ever emacs-y.

%\newpage
\appendix

%% \section{Index of Filenames}
@%% @%f
%% \section{Index of Fragments}
@%% @%m
%% \section{Index of User Specified Identifiers}
@%% @%u
\section{Plaintext Please}
Here are the plaintext files: \href{http://gnufoo.org/emacsy/emacsy.h}{emacsy.h},
\href{http://gnufoo.org/emacsy/hello-emacsy.c}{hello-emacsy.c},
\href{http://gnufoo.org/emacsy/emacsy-stub.c}{emacsy-stub.c}, and
\href{http://gnufoo.org/emacsy/.hello-emacsy}{.hello-emacsy}.

\section{Uninteresting Code}
Not particularly interesting bits of code but necessary to compile.

\lstset{basicstyle=\footnotesize}

@d Include Headers  @{@%
#include <GLUT/glut.h> 
#include <stdlib.h>
#include <libguile.h>
#include "emacsy.h"

void draw_string(int, int, char*);@%
@|@}

%Draw a string function.
@d Functions @{@%
/* Draws a string at (x, y) on the screen. */
void draw_string(int x, int y, char *string) {
  glLoadIdentity();
  glTranslatef(x, y, 0.);
  glScalef(0.2, 0.2, 1.0);
  while(*string) 
    glutStrokeCharacter(GLUT_STROKE_ROMAN, 
                        *string++);
}@%
@|@}

Setup the display buffer the drawing.
@d Display Setup @{@%
glClear(GL_COLOR_BUFFER_BIT);

glMatrixMode(GL_PROJECTION);
glLoadIdentity();
glOrtho(0.0, 500.0, 0.0, 500.0, -2.0, 500.0);
gluLookAt(0, 0, 2, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);

glMatrixMode(GL_MODELVIEW);
glColor3f(1,1,1);@%
@|@}

%Initialize GLUT.

@d GLUT Initialization @{@%
glutInit(&argc, argv);
glutInitDisplayMode(GLUT_RGB|GLUT_DOUBLE);
glutInitWindowSize(500, 500);
glutCreateWindow("Minimal Emacsy Example");
glutDisplayFunc(display_func);
glutKeyboardFunc(keyboard_func);@%
@|@}

%Our application has just one job.

@d Display the counter variable @{@%
char counter_string[255];
sprintf(counter_string, "%d", counter);
draw_string(250, 250, counter_string);@%
@|@}

%Stub file for emacsy.
@o emacsy-stub.c @{@%
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
}@%
@|@}

%% \section{hello-emacsy.c}

%% %\inputminted[bgcolor=bg]{hello-emacs.c}{c}
%% %% \begin{minted}[bgcolor=bg]{c}
%% %% 
%% %% \end{minted}
%% \lstinputlisting[basicstyle=\footnotesize,breaklines=false]{hello-emacsy.c}
%\end{multicols}

%% 

\end{document}
