module Const exposing (..)


const =
    { questions =
        [ { question = "In my free time, I prefer to..."
          , choices =
                [ { select = "Go out with friends"
                  , answer = "In your free time, you prefer to meet people. This might means that you are an extrovert, or simply hate watching movies."
                  }
                , { select = "Watch movie alone"
                  , answer = "In your free time, you prefer to watch movie alone than meeting people. It might be the case that you are an introvert, or possibly an extrovert that loves watching movies."
                  }
                ]
          }
        , { question = "I enjoy a trip that is ..."
          , choices =
                [ { select = "Filled with activity"
                  , answer = "You are an energetic person that enjoy a trip filled with activity."
                  }
                , { select = "Lightweight"
                  , answer = "You enjoy having a relaxed time rather than a wild trip filled with activity."
                  }
                ]
          }
        , { question = "I believe that this test define who I am."
          , choices =
                [ { select = "Agree"
                  , answer = "You do believe that this test define your personality, and you were almost correct."
                  }
                , { select = "Disagree"
                  , answer = "You don't think that the test define you, but to be fair, it does say what kind of person you are at the moment."
                  }
                ]
          }
        ]
    , ending = "This description is exactly what you think about yourselves. Don't put yourself into a group based on a few questions. People are more complicated than that. Embrace the differences."
    }
