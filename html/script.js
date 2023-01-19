let noselected = true
let alrS = true

$(document).ready(function () {
    $("body").hide()
});

window.addEventListener("message", function (event) {
    let data = event.data.data
    if (data !== undefined) {
        if (data === "nada") {
            $(".lds-facebook").hide()
            $(".borderTop").animate({
                height: "-=40%",
            }, 800)
            $(".borderBot").animate({
                height: "-=40%",
            }, 800)
            $(".box2").animate({
                right: "-=40%",
            }, 800)
            $("#name").append('<p><i class="fa fa-plus" aria-hidden="true"></i> Criar personagem </p>')
            $("#name").click(function () {
                if (noselected) {  
                    if (alrS) {
                        $(".box").animate({
                            left: "-=40%",
                        }, 500)
                        $(".geral").append('<div class="center"><br><input id="firstname" type="text" class = "inputer" placeholder="Nome"><br><br><input id="lastname" type="text" class = "inputer" placeholder="Sobrenome"><br><br><input id="dateofbirth" type="text" class = "inputer" placeholder="Data de nascimento [DD-MM-AAAA]"><br><br><input id="height" type="text" class = "inputer" placeholder="Altura [120-220 cm]"><br><center><br><label class="container">HOMEM<input type="radio" name="sex" value="m" checked><span class="checkmark"></span></label><label class="container">MULHER<input type="radio" name="sex" value="f" ><span class="checkmark"></span></label></center></div>')
                        $("#name").css("border", "2px solid rgb(100, 100, 99)")
                        $.post("http://pb_entrada/select", JSON.stringify({}))
                        noselected = false
                        alrS = false
                    } else {
                        $(".box").animate({
                            left: "-=40%",
                        }, 500)
                        $("#name").css("border", "2px solid rgb(100, 100, 99)")
                        $.post("http://pb_entrada/select", JSON.stringify({}))
                        noselected = false
                    }
                    $(".box").css("height", "340px")
                } else {
                    $(".box").animate({
                        left: "+=40%",
                    }, 500)
                    $("#name").css("border", "0px solid rgb(100, 100, 99)")
                    $.post("http://pb_entrada/unselect", JSON.stringify({}))
                    noselected = true
                }
            })
            $("#playbutton").click(function () {
                if (noselected === false) {
                    var date = $("#dateofbirth").val();
                    var dateCheck = new Date($("#dateofbirth").val());
            
                    if (dateCheck == "Invalid Date") {
                        date == "invalid";
                    }

                    $.post('http://pb_entrada/register', JSON.stringify({
                        firstname: $("#firstname").val(),
                        lastname: $("#lastname").val(),
                        dateofbirth: date,
                        sex: $("input[type='radio'][name='sex']:checked").val(),
                        height: $("#height").val()
                    }));
                }
            })
        } else if (data === "fechar") {
            $("body").hide()
        } else {
            let sexo = 'f'
            if (data.sex === 'm') {
                sexo = 'Masculino'
            } else {
                sexo = 'Feminino'
            }
            $(".lds-facebook").hide()
            $(".borderTop").animate({
                height: "-=40%",
            }, 800)
            $(".borderBot").animate({
                height: "-=40%",
            }, 800)
            $(".box2").animate({
                right: "-=40%",
            }, 800)
            $("#name").append('<p><i class="fa fa-user" aria-hidden="true"></i> ' + data.firstname.toUpperCase() + " " + data.lastname.toUpperCase() + '</p>')
            $("#name").click(function () {
                if (noselected) {
                    if (alrS) {
                        $(".box").animate({
                            left: "-=40%",
                        }, 500)
                        $(".geral").append('<ul class="lista1"><li><a href="#">Nome: </a></li><li><a href="#">Data Nascimento: </a></li><li><a href="#">Género:</a></li><li><a href="#">Trabalho:</a></li></ul><ul class="lista2"><li><a href="#">' + data.firstname + " " + data.lastname + '</a></li><li><a href="#">' + data.dateofbirth + '</a></li><li><a href="#">' + sexo + '</a></li><li><a href="#">' + data.job + '</a></li></ul>')
                        $("#name").css("border", "2px solid rgb(100, 100, 99)")
                        $.post("http://pb_entrada/select", JSON.stringify({}))
                        noselected = false
                        alrS = false
                    } else {
                        $(".box").animate({
                            left: "-=40%",
                        }, 500)
                        $("#name").css("border", "2px solid rgb(100, 100, 99)")
                        $.post("http://pb_entrada/select", JSON.stringify({}))
                        noselected = false
                    }

                } else {
                    $(".box").animate({
                        left: "+=40%",
                    }, 500)
                    $("#name").css("border", "0px solid rgb(100, 100, 99)")
                    $.post("http://pb_entrada/unselect", JSON.stringify({}))
                    noselected = true
                }
            });
            $("#playbutton").click(function () {
                if (noselected === false) {
                    $("body").hide()
                    $.post("http://pb_entrada/play", JSON.stringify({}))
                }
            })
        }
    } else if (event.data.start !== null) {
        $("body").show()    
    }
})