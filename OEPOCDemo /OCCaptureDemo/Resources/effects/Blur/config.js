var effectData = {
    reservedMeshId: {
        bgSeparationMesh: 7,
        blurBgMesh: 8,
    },

    meshes: {
        bgSeparation: "triBG2.bsm2",
        blurBg: "tri_Blur.bsm2",
    },

    shadersIDs: {
        angle: 1,
        bgRotation: 8,
        bgScale: 9,
        platformData: 10,
        blurRadius: 16,
    },

    meshesState: {
        bgSeparationCreated: false,
        bgBlurCreated: false,
    },

    bgState: {
        lastAngle: 0,
        currAngle: 0,
        lastScale: 0,
        currScale: 1,
    },
};

/** ------ effect ------- **/

function Effect()
{
    var self = this;

    this.init = function() {
        Api.showRecordButton();

        deleteBackground("true");
         initBlurBackground("true");
        // deleteBlurBackground("true");

//         initBackground("true");
//         setBackgroundTexture("rcv_bg_1.jpg");
        // deleteBackground("true");
    };

    this.restart = function() {
        Api.meshfxReset();
        self.init();
    };

    this.faceActions = [];
    this.noFaceActions = [];

    this.videoRecordStartActions = [];
    this.videoRecordFinishActions = [];
    this.videoRecordDiscardActions = [];
}

var effect = new Effect();

// Blur bg API

function initBlurBackground(modifyRecognizerFeatures) {
    if (modifyRecognizerFeatures && !effectData.meshesState.bgBlurCreated && !effectData.meshesState.bgSeparationCreated) {
        Api.print("initBackground - add Blur bg separation mesh");

        var id = effectData.reservedMeshId.blurBgMesh;
        var meshName = effectData.meshes.blurBg;
        Api.meshfxMsg("spawn", id, 0, meshName);

        setBlurRadius(3.);

        effectData.meshesState.bgBlurCreated = true;
    } else {
        Api.print("initBackground - cannot initialize already initialized Blur bg mesh");
    }
}

function setBlurRadius(floatRadius){
    if (floatRadius > 8 || floatRadius < 3) {
        Api.print("setBlurRadius - set radius in range [3.,8.] as float value.");
    } else {
        var blurShaderId = effectData.shadersIDs.blurRadius;

        Api.meshfxMsg("shaderVec4", 0, blurShaderId, floatRadius + " 0 0 0");
        Api.print("setBlurRadius - radius is set to " + floatRadius);
    }
}


function deleteBlurBackground(modifyRecognizerFeatures) {
    if (effectData.meshesState.bgBlurCreated && modifyRecognizerFeatures) {
        Api.print("deleteBackground - remove Blur bg separation mesh");
        Api.meshfxMsg("del", effectData.reservedMeshId.blurBgMesh);
        effectData.meshesState.bgBlurCreated = false; // ---------------------------<
    } else {
        Api.print("deleteBackground - cannot delete already deleted Blur bg separation mesh");
    }
}

// BG API

function initBackground(modifyRecognizerFeatures) {
    if (modifyRecognizerFeatures && !effectData.meshesState.bgSeparationCreated && !effectData.meshesState.bgBlurCreated) {
        Api.print("initBackground - add bg separation mesh");

        var id = effectData.reservedMeshId.bgSeparationMesh;
        var meshName = effectData.meshes.bgSeparation;
        Api.meshfxMsg("spawn", id, 0, meshName);

        effectData.meshesState.bgSeparationCreated = true;
    } else {
        Api.print("initBackground - cannot initialize already initialized bg mesh");
    }

    setBgRotation(effectData.bgState.currAngle);
    setBgScale(1);
}

function resetBgState() {
    effectData.bgState.bgScale = 1.0;
    effectData.bgState.currAngle = 0;
    setBgRotation(effectData.bgState.currAngle);
    setBgScale(effectData.bgState.bgScale);
}

function setBackgroundTexture(textureName) {
    if (!effectData.meshesState.bgSeparationCreated) {
        Api.print("cannot set bg texture because mesh is not created");
        return;
    }
    resetBgState();
    Api.meshfxMsg("tex", effectData.reservedMeshId.bgSeparationMesh, 0, textureName);
}

function rotateBg(angle) {
    effectData.bgState.currAngle += angle;
    setBgRotation(effectData.bgState.currAngle);
}

function scaleBg(scale) {
    effectData.bgState.currScale += scale;
    setBgScale(effectData.bgState.currScale);
}

function setBgRotation(angle) {
    if (!effectData.meshesState.bgSeparationCreated) {
        Api.print("cannot set bg rotation because mesh is not created");
        return;
    }

    Api.meshfxMsg("shaderVec4", 0, effectData.shadersIDs.bgRotation, angle + " 0 0 0");
}

function setBgScale(scale) {
    if (!effectData.meshesState.bgSeparationCreated) {
        Api.print("cannot set bg scale because mesh is not created");
        return;
    }

    Api.meshfxMsg("shaderVec4", 0, effectData.shadersIDs.bgScale, scale + " 0 0 0");
}

function deleteBackground(modifyRecognizerFeatures) {
    if (effectData.meshesState.bgSeparationCreated && modifyRecognizerFeatures) {
        Api.print("deleteBackground - remove bg separation mesh");
        Api.meshfxMsg("del", effectData.reservedMeshId.bgSeparationMesh);
        effectData.meshesState.bgSeparationCreated = false;
    } else {
        Api.print("deleteBackground - cannot delete already deleted bg separation mesh");
    }
}

configure(effect);
