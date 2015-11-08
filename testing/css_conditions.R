# if(koti_condition){

#             ui_koti_emphasis_box_add = try(addClass("ui_koti_emphasis", "emph_box_koti"))
#             ui_tyo_emphasis_box_remove = try(removeClass("ui_tyo_emphasis", "emph_box_tyo"))
#             ui_potentiaalinen_emphasis_box_remove = try(removeClass("ui_potentiaalinen_emphasis", "emph_box_potentiaalinen"))
#             
#             if(class(ui_koti_emphasis_box_add)!='try-error') {addClass("ui_koti_emphasis", "emph_box_koti")}
#             if(class(ui_tyo_emphasis_box_remove)!='try-error') {removeClass("ui_tyo_emphasis", "emph_box_tyo")}
#             if(class(ui_potentiaalinen_emphasis_box_remove)!='try-error') {removeClass("ui_potentiaalinen_emphasis", "emph_box_potentiaalinen")}

# if(tyo_condition){


#           ui_tyo_emphasis_box_add = try(addClass("ui_tyo_emphasis", "emph_box_tyo"))
#           ui_koti_emphasis_box_remove = try(removeClass("ui_koti_emphasis", "emph_box_koti"))
#           ui_potentiaalinen_emphasis_box_remove = try(removeClass("ui_tyo_emphasis", "emph_box_tyo"))
#           
#           if(class(ui_tyo_emphasis_box_add)!='try-error') {addClass("ui_tyo_emphasis", "emph_box_tyo")}
#           if(class(ui_koti_emphasis_box_remove)!='try-error') {removeClass("ui_koti_emphasis", "emph_box_koti")}
#           if(class(ui_potentiaalinen_emphasis_box_remove)!='try-error') {removeClass("ui_tyo_emphasis", "emph_box_tyo")}


# if(potentiaalinen_condition){

#           ui_potentiaalinen_emphasis_box_add = try(addClass("ui_potentiaalinen_emphasis", "emph_box_potentiaalinen"))
#           ui_koti_emphasis_box_remove = try(removeClass("ui_koti_emphasis", "emph_box_koti"))
#           ui_tyo_emphasis_box_remove = try(removeClass("ui_tyo_emphasis", "emph_box_tyo"))
#           
#           if(class(ui_potentiaalinen_emphasis_box_add)!='try-error') {addClass("ui_potentiaalinen_emphasis", "emph_box_potentiaalinen")}
#           if(class(ui_koti_emphasis_box_remove)!='try-error') {removeClass("ui_koti_emphasis", "emph_box_koti")}
#           if(class(ui_tyo_emphasis_box_remove)!='try-error') {removeClass("ui_tyo_emphasis", "emph_box_tyo")}
