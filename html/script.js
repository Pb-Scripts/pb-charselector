let peds_info = [];
let selectedCid = null;
let gender = null
let newcharopen = false;
let locales = null;

var entityMap = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#39;',
    '/': '&#x2F;',
    '': '&#x60;',
    '=': '&#x3D;'
};

function escapeHtml(string) {
    return String(string).replace(/[&<>"'=/]/g, function (s) {
        return entityMap[s];
    });
}
function hasWhiteSpace(s) {
    return /\s/g.test(s);
}

$(document).ready(function(){

    $(".wrapper").hide();
    $(".charwrapper").hide();
    $(".AddNewChar").hide();
    $(".CharsCreation").hide();

    window.addEventListener('message', function (event) {
        let data = event.data
        let type = data.type
        if (type === "loadChar") {
            peds_info[data.cid] = data.info;
            let charinfo = peds_info[data.cid]
            $('.CharsSelection').append('<div class="charSelectorDiv" data-name="'+ charinfo.firstname + ' ' + charinfo.lastname +'" data-gender="'+ charinfo.gender +'" data-cid="'+ data.cid +'" style="left: '+data.left+'%; top: '+data.top+'%;"></div>');
            if (data.last) {
                $(".wrapper").show();
                $.post('https://pb-charselector/RemoveBlur', JSON.stringify({}));
            }; 
        } else if (type === "CreateNewCharSetup") {
            if (data.num < data.max) {
                if (data.removeblur) {
                    $(".wrapper").show();
                    $.post('https://pb-charselector/RemoveBlur', JSON.stringify({}));
                }
                $(".AddNewChar").fadeIn(500);
                locales = data.dict

                $(".CharsCreation").append(`
                    <div id="gender-male">` + locales["gender_male"] + `</div>
                    <div id="gender-female">` + locales["gender_female"] + `</div>


                    <div class="list-label">
                        <div>` + locales["firstname"] + `</div>
                        <input id="firstname" type="text"/>
                    </div>

                    <div class="list-label">
                        <div>` + locales["lastname"] + `</div>
                        <input id="lastname" type="text"/>
                    </div>

                    <div class="list-label">
                        <div>` + locales["nacionality"] + `</div>
                        <input id="nationality" type="text"/>
                    </div>

                    <div class="list-label">
                        <div>` + locales["born"] + `</div>
                        <input id="born" min="1900-01-01" max="2999-12-31" type="date"/>
                    </div>

                    <div class="buttonswrapper">
                        <div id="cancelchar" class="buttonchar delete">` + locales["cancel"] + `</div>
                        <div id="createchar" class="buttonchar select">` + locales["select"] + `</div>
                    </div>`
                )
            }
        };
    });
});

$(document).on('click', '.charSelectorDiv', function(event) {
    event.preventDefault();
    if (!newcharopen) {
        let name = $(this).data("name");
        let cid = $(this).data("cid");
        let gender = $(this).data("gender");
        if (gender == 0) { gender = "Masculino"} else { gender = "Feminino" }
        selectedCid = cid
        $(".charwrapper").fadeOut(150);
        $(".charwrapper").html("");
        $(".charwrapper").fadeIn(150);
        $(".charwrapper").append(
            `<div class="charinfowrapper">
                <div class="charinfo">
                    <div class="charname"><strong>`+ name +`</strong></div>
                    <div class="charcsn infochar"><i class="far fa-id-card infocharicon"></i>`+ cid +`</div>
                    <div class="chargender infochar"><i class="fa-solid fa-person infocharicon"></i>` + gender + `</div>
                </div>
            </div>
            <div class="buttonswrapper">
                <div id="deletechar" class="buttonchar delete">` + locales["delete"] + `</div>
                <div id="selectchar" class="buttonchar select">` + locales["select"] + `</div>
            </div>`
        );
    }
})

$(document).on('click', '#deletechar', function(event) {
    event.preventDefault();
    $.post('https://pb-charselector/DeleteCharacter', JSON.stringify({
        cid: selectedCid,
    }));
    ResetHUD()
})

$(document).on('click', '#selectchar', function(event) {
    event.preventDefault();
    $.post('https://pb-charselector/SelectChar', JSON.stringify({
        cid: selectedCid,
    }));
    ResetHUD()
})

$(document).on('click', '.AddNewChar', function(event) {
    event.preventDefault();
    newcharopen = true;
    $(".charwrapper").fadeOut(500);
    $(".CharsCreation").fadeIn(500);
})

$(document).on('click', '#createchar', function(event) {
    event.preventDefault();
    let firstname = $("#firstname").val();
    let lastname = $("#lastname").val();
    let nationality = $("#nationality").val();
    let birthdate = escapeHtml($("#born").val());
    let success = true;
    if (!firstname || !lastname || !nationality || !birthdate) {
        $.post('https://pb-charselector/errorNotify', JSON.stringify({
            text: locales["notallfilled"]
        }));
        success = false;
    }
    if (hasWhiteSpace(firstname) || hasWhiteSpace(lastname)|| hasWhiteSpace(nationality)) {
        $.post('https://pb-charselector/errorNotify', JSON.stringify({
            text: locales["blanckspaces"]
        }));
        success = false;
    }
    if (gender == null) {
        $.post('https://pb-charselector/errorNotify', JSON.stringify({
            text: locales["no_gender" ]
        }));
        success = false;
    }
    if (success) {
        $.post('https://pb-charselector/CreateChar', JSON.stringify({
            firstname: firstname,
            lastname: lastname,
            nationality: nationality,
            birthdate: birthdate,
            gender: gender,
        }));
        ResetHUD();
    }
})

$(document).on('click', '#cancelchar', function(event) {
    event.preventDefault();
    $(".CharsCreation").fadeOut(500);
    $("#firstname").val("");
    $("#lastname").val("");
    $("#nationality").val("");
    $("#born").val("");
    gender = null;
    newcharopen = false;
})

$(document).on('click', '#gender-male', function(event) {
    event.preventDefault();
    gender = 0;
})

$(document).on('click', '#gender-female', function(event) {
    event.preventDefault();
    gender = 1;
})

function ResetHUD() {
    $(".charwrapper").fadeOut(150);
    $(".charwrapper").html("");
    $(".CharsSelection").html("");
    $(".CharsCreation").html("");
    $(".AddNewChar").hide();
    $(".CharsCreation").hide();
    $(".wrapper").hide();
    $("#firstname").val("");
    $("#lastname").val("");
    $("#nationality").val("");
    $("#born").val("");
    gender = null;
    newcharopen = false;
}
